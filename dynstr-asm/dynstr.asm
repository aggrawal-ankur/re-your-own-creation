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

