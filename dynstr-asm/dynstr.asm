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
  xor rcx, rcx    # SUCCESS hoisted

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
  xor rcx, rcx    # SUCCESS hoisted

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


.global tolcase
.type tolcase, @function

# Function Parameters
#   rdi=str (const char*)
#   rsi=lcase (caller-allocated buffer to put the lowercase string into)
tolcase:
  push rbx    # rsi
  push r13    # len(str)
  sub  rsp, 8

  test rdi, rdi
  jz   .invalid_buff_p13

# copystr inlined; memcpy, basically
# preserve rsi only as rdi is no longer used after this.
  mov rbx, rsi

  mov rsi, rdi  # Arg2 (rsi=str)
  mov rdi, rsi  # Arg1 (rdi=lcase)

  # Arg3 (rdx=bytes) need to be calculated
  xor r13, r13
.len_p13:
  cmp BYTE PTR [rdi + r13], 0
  jz  .done_p13

  add r13, 1
  jmp .len_p13

.done_p13:
  test r13, r14
  jz   .invalid_buff_p13

  mov rdx, r13    # Arg3 (rdx=r13=bytes)
  call memcpy@PLT
  mov BYTE PTR [rbx + r13], 0
  
# Loop over each character and run char2lcase on it.
  xor rax, rax    # iterator
.convert2lcase_p13:
  mov dl, BYTE PTR [rbx + rax]
  cmp dl, 0
  jz  .check_lcase_p13

  # char2lcase inlined;
  cmp dl, 65
  jb .end_p13    # Not uppercase, do nothing.
  cmp dl, 90
  ja .end_p13    # Not uppercase, do nothing.

  or dl, 0x20     # Uppercase confirmed, convert.
  mov BYTE PTR [rbx + rax], dl    # lcase[i] = char2lcase(lcase[i])

.end_p13:
  add rax, 1
  jmp .check_lcase_p13

# islcase inlined
  xor eax, eax    # SUCCESS hoisted
  xor rcx, rcx    # iterator
.check_lcase_p13:
  mov dl, BYTE PTR [rbx + rcx]
  cmp dl, 0
  jz  .ret_block_p13

  cmp dl, 65
  jae .lcase_failed_p13
  cmp dl, 90
  jbe .lcase_failed_p13

  add rcx, 1
  jmp .check_lcase_p13

.invalid_buff_p13:
  mov eax, -6
  jmp .ret_block_p13

.lcase_failed_p13:
  mov eax, -11

.ret_block_p13:
  add rsp, 8
  pop r13
  pop rbx
  ret


.global toucase
.type toucase, @function

# Function Parameters:
#   rdi=str (const char*)
#   rsi=ucase (char*) (callee-allocated buffer to put the uppercase string into)
toucase:
  push rbx
  push r13
  sub  rsp, 8

  test rdi, rdi
  jz   .ret_block_p14

# copystr inlined; memcpy, basically
# preserve rsi as rdi is not used after.
  mov rbx, rsi

  mov rsi, rdi  # Arg2 (rsi=str)
  mov rdi, rsi  # Arg1 (rdi=ucase)

  # Arg3 (rdx=bytes) needs calculation
  xor r13, r13
.len_p14:
  cmp BYTE PTR [rbx + r13], 0
  jz  .done_p14

  add r13, 1
  jmp .len_p14

.done_p14:
  test r13, r13
  jz   .invalid_buff_p14

  mov  rdx, r13  # Arg3 (rdx=bytes)
  call memcpy@PLT
  mov BYTE PTR [rbx + r13], 0

# loop over each character and run char2ucase
  xor rax, rax
.convert2ucase_p14:
  mov dl, BYTE PTR [rbx + rax]
  cmp dl, 0
  jz  .check_ucase_p14

  # char2ucase inlined;
  cmp dl, 97
  jb  .end_p14    # Not lowercase, do nothing.
  cmp dl, 122
  ja  .end_p14    # Not lowercase, do nothing.

  and dl, -33     # Lowercase confirmed, convert.
  mov BYTE PTR [rbx + rax], dl

.end_p14:
  add rax, 1
  jmp .convert2ucase_p14

# isucase inlined
  xor eax, eax    # SUCCESS hoisted
  xor rcx, rcx    # iterator
.check_ucase_p14:
  mov dl, BYTE PTR [rbx + rcx]
  cmp dl, 0
  jz  .ret_block_p14

  cmp dl, 97
  jae .ucase_failed_p14
  cmp dl, 122
  jbe .ucase_failed_p14

  add rcx, 1
  jmp .check_ucase_p14

.invalid_buff_p14:
  mov eax, -6
  jmp .ret_block_p14

.ucase_failed_p14:
  mov eax, -12

.ret_block_p14:
  add rsp, 8
  pop r13
  pop rbx
  ret

