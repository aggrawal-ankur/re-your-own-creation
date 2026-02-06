.file "dynstr.asm"
.intel_syntax noprefix

.section .text
.global init
.type init, @function

# Function Parameters
#   rdi=&str (dynamic string struct)
#   rsi=capacity
init:
  push r14
  push r15
  sub  rsp, 8

  mov  eax, -1    # No separate branch because it's destined to execute if init is ran on an initialized dynstr by mistake
  test rdi, rdi
  jnz  .ret_block_p1

  test rsi, rsi
  jz   .invalid_cap_p1

# malloc; preserve rdi and rsi
  mov r14, rdi
  mov r15, rsi

  mov  rdi, rsi
  call malloc@PLT
  test rax, rax
  jz   .malloc_failed

  mov QWORD PTR   [r14], rax
  mov QWORD PTR  8[r14], 0
  mov QWORD PTR 16[r14], r15

  xor eax, eax
  jmp .ret_block_p1

.invalid_cap_p1:
  mov eax, -2
  jmp .ret_block_p1

.malloc_failed:
  mov eax, -3

.ret_block_p1:
  add rsp, 8
  pop r15
  pop r14
  ret


.global extendCap
.type extendCap, @function

# Function Parameters:
#   rdi=&str
#   rsi=add  (new bytes to add)
extendCap:
  push r14
  push r15
  sub  rsp, 8

  mov  eax, -4
  test rdi, rdi
  jz   .ret_block_p2

  mov  rcx, QWORD PTR [rdi]
  test rcx, rcx
  jz   .ret_block_p2

  mov rcx, QWORD PTR 16[rdi]
  cmp rcx, rsi
  ja  .success_p2

.inc_cap:
  shl rcx, 1
  cmp rcx, rsi
  jb .inc_cap

# realloc; preserve rdi only as rsi is not used anymore. Also, rcx (the new capacity) needs to be preserved.
  mov r14, rdi
  mov r15, rcx

  mov  rdi, QWORD PTR [rdi]
  mov  rsi, rcx
  call realloc@PLT
  test rax, rax
  jz   .realloc_failed_p2

  mov QWORD PTR   [r14], rax
  mov QWORD PTR 16[r14], r15
  jmp .success

.realloc_failed_p2:
  mov eax, -5
  jmp .ret_block_p2

.success_p2:
  xor eax, eax

.ret_block_p2:
  add rsp, 8
  pop r15
  pop r14
  ret

.global lenstr
.type lenstr, @function

# Function Parameters:
#   rdi=*buff (const char)
lenstr:
  xor eax, eax
.len:
  cmp BYTE PTR [rdi + eax], 0
  jz  .ret_block_p3

  add eax, 1
  jmp .len

.ret_block_p3:
  ret


.global populate
.type populate, @function

# Function Parameters:
#   rdi=dest (dynstr to populate)
#   rsi=src  (buffer to copy in dest, const char*)
populate:
  push rbx
  push r14
  push r15

  mov  eax, -4
  test rdi, rdi
  jz   .ret_block_p4

  mov  rcx, QWORD PTR [rdi]
  test rcx, rcx
  jz   .ret_block_p4

  test rsi, rsi
  jz   .invalid_buff_p4

# preserve rdi and rsi
  mov r14, rdi
  mov r15, rsi

# lenstr inlined
  xor ebx, ebx
.len_p4:
  cmp BYTE PTR [rsi + ebx], 0
  jz  .done_p4
  add ebx, 1
  jmp .len_p4

  movzx r13, ebx
  add   r13, 8[rdi]    ; nlen

  # Arg1 (rdi=dest) already set
  mov  rsi, r13
  add  rsi, 1
  call extend
  test eax, eax
  jnz  .ret_block_p4

# memcpy;
  movzx rdx, ebx
  mov   rsi, r15

  mov rdi, r14
  add rdi, QWORD PTR 8[r14]

  call memcpy@PLT
  
  mov QWORD PTR 8[r14], r13
  mov rcx, QWORD PTR [r14]
  mov QWORD PTR [rcx + r13], 0
  xor eax, eax

.done_p4:
  test ebx, ebx
  jz   .invalid_buff_p4

.invalid_buff_p4:
  mov eax, -6

.ret_block_p4:
  pop r15
  pop r14
  pop rbx
  ret


.global boundcheck
.type boundcheck, @function

# Function Parameters:
#   rdi=lb
#   rsi=ub
#   rdx=idx
boundcheck:
  xor eax, eax
  cmp rdx, rsi
  jae .ret_block_p5
  mov eax, 1

.ret_block_p5:
  ret


.global getstr
.type getstr, @function

# Function Parameters:
#   rdi=&str (dynstr)
#   rsi=idx
#   rdx=out_ptr (char**)
getstr:
  mov  eax, -4
  test rdi, rdi
  jz   .ret_block_p6

  mov rcx, QWORD PTR [rdi]
  jz  .ret_block_p6

# boundcheck inlined;
  cmp rsi, QWORD PTR 8[rdi]
  jae .invalid_idx_p6

  # I am not sure about this!
  mov rdx, QWORD PTR [rdx]    # *out
  mov rdi, QWORD PTR [rdi]    # str->data
  lea rdx, [rdi + rsi]        # *out = str->data[idx]

  xor eax, eax
  jmp .ret_block_p6

.invalid_idx_p6:
  mov eax, -7

.ret_block_p6:
  ret


.global getslicedstr
.type getslicedstr, @function

# Function Parameters:
#   rdi=&str (dynstr)
#   rsi=start
#   rdx=end
#   r10=&outstr (callee allocated buffer)
getslicedstr:
  push r13
  push r14
  push r15

  mov  eax, -4
  test rdi, rdi
  jz   .ret_block_p7

  mov  rcx, QWORD PTR [rdi]
  test rcx, rcx
  jz   .ret_block_p7

# range validation
  mov rcx, QWORD PTR 8[rdi]
  cmp rsi, rcx
  jae .ret_block_p7
  cmp rdx, rcx
  jae .ret_block_p7

# memcpy; preserve rdi and r10 and compute slen in a callee-saved register
  mov r13, rdi
  mov r14, r10
  mov r15, [rdx - rsi]

  # Arg2 (rsi=&str->data[start])
  mov rcx, rsi    # preserve start
  mov rsi, QWORD PTR [r14]          # str->data (base)
  lea rsi, QWORD PTR [r14 + rcx]    # &str->data[start]

  mov  rdx,  r15     # Arg3 (rdx=slen)
  mov  rdi, [r14]    # Arg1 (rdi=outstr)
  call memcpy@PLT
  mov QWORD PTR [r14 + r15], 0

  xor eax, eax
  jmp .ret_block_p7

.invalid_range_p7:
  mov eax, -8

.ret_block_p7:
  pop r15
  pop r14
  pop r13
  ret


.global copystr
.type copystr, @function

# Function Parameters:
#   rdi=src  (const char*)
#   rsi=dest (char*)
copystr:
  push rbx
  push r14
  sub  rsp, 8

  test rdi, rdi
  jz   .invalid_buff_p8

# lenstr inlined;
  xor ebx, ebx
len_p8:
  cmp BYTE PTR [rdi + ebx], 0
  jz  .done_p8
  add ebx, 1
  jmp .len_p8

# memcpy; preserve rdi
  mov r14, rdi

  mov   rdi, rsi
  mov   rsi, r14
  movzx rdx, ebx
  call  memcpy@PLT

  xor eax, eax
  jmp .ret_block_p8

.done_p8:
  test ebx, ebx
  jz   .invalid_buff_p8

.invalid_buff_p8:
  mov eax, -6

.ret_block_p8:
  add rsp, 8
  pop r14
  pop rbx
  ret


.global char2lcase
.type char2lcase, @function

# Function Parameters
#   dil=c (char)  (dil=lower 8-bits of rdi)
char2lcase:
  mov al, dil

  cmp dil, 65
  jb  .ret_block_p9
  cmp dil, 90
  ja  .ret_block_p9

  or  al, 0x20

.ret_block_p9:
  ret

.global char2ucase
.type char2ucase, @function

# Function Parameters
#   dil=c (char)  (dil=lower 8-bits of rdi)
char2ucase:
  mov al, dil

  cmp dil, 97
  jb  .ret_block_p10
  cmp dil, 122
  ja  .ret_block_p10

  and al, -33    # (~0x20)

.ret_block_p10:
  ret

.global islcase
.type islcase, @function

# Function Parameters
#   rdi=str  (const char*)
islcase:
  test rdi, rdi
  jz   .invalid_buff_p11

  mov eax, -9
  xor rcx, rcx

.check_loop_p11:
  mov dl, BYTE PTR [rdi + rcx]
  cmp dl, 0
  jz  .done_p11

  cmp dl, 65
  jb  .ret_block_p11
  cmp dl, 90
  ja  .ret_block_p11

  add rcx, 1
  jmp .check_loop_p11

.invalid_buff_p11:
  mov eax, -6
  jmp .ret_block_p11

.done_p11:
  test rcx, rcx
  jz   .ret_block_p11

.success_p11:
  xor eax, eax

.ret_block_p11:
  ret


.global isucase
.type isucase, @function

# Function Parameters:
#   rdi=str (const char*)
isucase:
  test rdi, rdi
  jz   .invalid_buff_p12

  mov eax, -9
  xor rcx, rcx

.check_loop_p12:
  mov dl, BYTE PTR [rdi + rcx]
  cmp dl, 0
  jz  .done_p12

  cmp dl, 97
  jb  .ret_block_p12
  cmp dl, 122
  ja  .ret_block_p12

  add rcx, 1
  jmp .check_loop_p12

.invalid_buff_p12:
  mov eax, -6
  jmp .ret_block_p12

.done_p12:
  test rcx, rcx
  jz   .ret_block_p12

.success_p12:
  xor eax, eax

.ret_block_p12:
  ret

