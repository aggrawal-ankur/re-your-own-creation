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

  mov QWORD PTR [rbx + 8*0], rax     # arr->ptr = rax (malloc's return value)
  mov QWORD PTR [rbx + 8*1], rsi     # arr->elem_size (rsi)
  mov QWORD PTR [rbx + 8*2], 0       # arr->count     (initialize with 0)
  mov QWORD PTR [rbx + 8*3], rcx     # arr->capacity  (rcx)

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
  # Note: ALWAYS pop registers in opposite order of push
  pop r12
  pop rbx
  leave
  ret


# Function Parameters
#   rdi=&arr (pointer to the dynamic array struct)
#   rsi=add_bytes (extra bytes required, size_t)
extend:
  push rbp          # preserve old base pointer
  mov  rbp, rsp     # setup new base-ptr for current procedure

# if (!arr || arr->capacity == 0)
#   rdi is live in this region, along with rcx which holds a member value pointed to by rdi (arr->capacity)
  test rdi, rdi
  jz   .init_first

  mov  rcx, QWORD PTR [rdi + 8*3]    # arr->capacity
  test rcx, rcx
  jz   .init_first

# if (arr->count+add_bytes <= arr->capacity)
#   members of rdi (rcx and other dereferenced) along with rsi are active in this region
  mov  r10, QWORD PTR [rdi + 8*2]
  add  r10, rsi    # arr->count+add_bytes (i.e `total`, later)
  cmp  r10, rcx
  jle .success

# Now we need space for two variables: (total, cap)
#   `total` is already computed in r10, and rcx represents arr->capacity already
#   No need for for other registers because this region of code doesn't require anything new
#   rcx undergoes changes (cap *= 2) and it's not a form of bad code because the original value is still intact in arr->capacity (via rdi + 8*3)

# while (cap < total) cap *= 2
.inc_cap:
#  We are doing updation first because the condition is checked for the first time outside the loop already
#  This is basically while loop changed to a do-while:
#    `do { cap *= 2 } while ( cap < total);`
  shl rcx, 1    # cap *= 2
  cmp rcx, r10
  jl .inc_cap

# To call realloc, we've to override rdi and rsi, which have the params passed to the `extend` procedure
#   rdi has the pointer to the dynamic array struct, so touching that makes no sense
#   rsi has add_bytes which is not active in this or any region forward. We can override rsi without any worries
.realloc:
  mov  r11, rdi            # r11 = ptr to dynamic array struct (preserve rdi in r11)
  mov  rsi, [rdi + 8*1]    # rsi = arr->elem_size
  imul rsi, rcx            # rsi = arr->elem_size*cap
  mov  rdi, [rdi + 8*0]    # rdi = &arr->ptr
  call realloc@PLT
  test rax, rax
  jz   .realloc_failed

  mov QWORD PTR [r11 + 8*0], rax    # arr->ptr = tmp
  mov QWORD PTR [r11 + 8*3], rcx    # arr->capacity = cap
  jmp .success

.init_first:
  mov rax, -5
  jmp .ret_block

.realloc_failed:
  mov rax, -6
  jmp .ret_block

.success:
  xor rax, rax

.ret_block:
  leave
  ret
