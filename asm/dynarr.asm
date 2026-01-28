.file "dynarr.asm"
.intel_syntax noprefix

.section .text
.global init
.type init, @function

# Function Parameters:
#   rdi=&arr (pointer to the dynamic array)
#   rsi=elem_size (data type's size, a 64-bit value)
#   rdx=cap (capacity, a 64-bit value)
init:
  push rbp         # old base-ptr reservation
  mov  rbp, rsp    # new base-ptr for current procedure
  push rbx         # callee-saved
  push r12         # A dummy push to realign the stack to a 16-byte boundary because we are calling malloc
  # No stack space required

# if (arr->capacity != 0)
  mov  rbx, QWORD PTR [rdi + 8*3]          # arr->capacity
  test rbx, rbx     # `arr->capacity` == 0
  jnz  .already_init

# if (elem_size == 0 || cap == 0)
  test rsi, rsi     # `elem_size` == 0
  jz   .invalid_sizes

# if (cap == 0)
  test rdx, rdx
  jz   .invalid_sizes

# if (cap > SIZE_MAX/elem_size) return SIZEMAX_OVERFLOW;
# Instead of preventing the overflow, we let it happen and use the CARRY FLAG in RFLAGS register to decide what to do
  mov  rcx, rdx    # preserve rdx (cap) as mul will clobber rdx
  mov  rax, rdx    # rax = cap
  mul  rsi         # (rax * rsi) == (cap * elem_size)  Result => rdx:rax {rdx:64-127 bits, rax:0-63 bits}
  test rdx, rdx    # Check if result overflowed to rdx
  jnz  .sizemax_overflow     # Jump if rdx is non-zero

  mov  rbx, rdi    # preserve the pointer to DynArr
  mov  rdi, rax    # Reuse rax as it contains (cap * elem_size) from previous computation
  call malloc@PLT
  test rax, rax    # NULL check on the pointer returned by malloc
  jz   .malloc_failed

  mov QWORD PTR [rbx + 8*0], rax     ; arr->ptr = rax (malloc's return value)
  mov QWORD PTR [rbx + 8*1], rsi     ; arr->elem_size (rsi)
  mov QWORD PTR [rbx + 8*2], 0       ; arr->count     (initialize with 0)
  mov QWORD PTR [rbx + 8*3], rcx     ; arr->capacity  (rcx)

  xor rax, rax      # rax=SUCCESS (0)
  jmp .ret_block

.already_init:
  mov rax, -1
  jmp .ret_block

.invalid_sizes:
  mov rax, -2
  jmp .ret_block

.sizemax_overflow:
  mov rax, -3
  jmp .ret_block

.malloc_failed:
  mov rax, -4
  jmp .ret_block

.ret_block:
  # Note: pop registers in order, ALWAYS.
  pop r12
  pop rbx
  leave
  ret
