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
  # No stack space required; No callee-saved register required

# if (arr->capacity != 0)
  mov  rcx, QWORD PTR [rdi + 8*3]     # arr->capacity
  test rcx, rcx                       # `arr->capacity` == 0
  jnz  .already_init

# if (elem_size == 0 || cap == 0)
  test rsi, rsi        # `elem_size` == 0
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

  mov  rcx, rdi    # preserve the pointer to DynArr
  mov  rdi, rax    # Reuse rax as it contains (cap * elem_size) from previous computation
  call malloc@PLT
  test rax, rax    # NULL check on the pointer returned by malloc
  jz   .malloc_failed

  mov QWORD PTR [rcx + 8*0], rax     # arr->ptr = rax (malloc's return value)
  mov QWORD PTR [rcx + 8*1], rsi     # arr->elem_size (rsi)
  mov QWORD PTR [rcx + 8*2], 0       # arr->count     (initialize with 0)
  mov QWORD PTR [rcx + 8*3], rcx     # arr->capacity  (rcx)

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
  leave
  ret

.section .text
.global extend
.type extend, @function

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


.section .text
.global pushOne
.type pushOne, @function

# Function Parameters:
#   rdi=&arr   (ptr to the dynamic array struct)
#   rsi=&value (ptr to the value to be pushed in the arr->ptr, type:void)
pushOne:
  push rbp
  mov  rbp, rsp
  push r14
  push r15

  test rdi, rdi      # !arr
  jz .init_first

  mov  rcx, [rdi + 8*1]     # rcx=arr->elem_size
  test rcx, rcx             # !arr->elem_size
  jz   .init_first

  mov  r8, [rdi + 8*3]      # r8=arr->capacity
  test r8, r8               # !arr->capacity
  jz   .init_first

# if (arr->count+1 > arr->capacity)
#   We need two registers here, one for (arr->count+1) and the other for arr->capacity
#   In this region of code, only arr->count and arr->capacity are active, that means, we can overwrite rcx which holds arr->elem_size currently (as the original value is intact at rdi + 8*1)
  mov rcx, [rdi + 8*2]      # rcx=arr->count
  add rcx, 1                # rcx=arr->count+1
  cmp rcx, r8

# This is an important decision point.
#   If I use `jg .call_extend`, I'll have to create a separate label for memcpy stuff because calling extend doesn't mean we will skip the rest of the code. If extend was successful, we have to go to the memcpy part, always.
#   If I make `.call_extend` the happy path, I can remove it as a label and only keep the memcpy label, to which we will jump if it were less than or eequal to. This way, we can prevent extra branching.
  jle  .memcpy_label        # if (arr->count+1 <= arr->capacity)

# extend takes 2 argument (ptr to the dynarr struct, add_bytes)
#   Since we are only pushing one element add_bytes (rsi) would be 1
#   Notice the argument is exactly what pushOne has received in rdi, so rdi needs no manipulation, but that model of thikning is wrong. As we call extend, pushOne becomes a caller-saved register and as caller it must preserve it if it want to use it later, so we'll preserve rdi in a callee-saved register (r14)
#   Since rsi contains the ptr to the value to push, we need to save rsi in a calle-saved register (r15)
#   In this region, only &arr (or rdi) is active. While arr->count (rcx) is still of use in later regions, arr->capacity (r8) is of no use now, so we can overwrite r8 to preserve rsi
  mov  r14, rdi    # preserve rdi (&arr)
  mov  r15, rsi    # preserve rsi (&value_to_push)
  mov  rsi, 1
  call extend     # extend(arr, 1)

  test rax, rax
  jnz  .ret_block     # No need to set rax as it is already set with appropriate return value

# `void *dest = (char*)arr->ptr + (arr->count * arr->elem_size);`
#   This line is about computing the destination memory address where memcpy will start copying memory
#   3 values are live here: arr->ptr, arr->count and arr->elem_size
#   arr->count is already live in rcx but we can't rely on it as it is a caller-saved register and we've made a call to extend which could've polluted it. We'll populate rcx again from the memory directly
#   We need to obtain arr->ptr fresh.
#   Since arr->elem_size has been overwritten, we need it fresh again. Since we need it as 3rd arg to memcpy, we'll use rdx for it

  # Set arg3 (rsi=arr->elem_size)
  mov  rdx, [r14 + 8*1]     # arr->elem_size

  # Set arg2 (rsi=&value)
  mov  rsi, r15            # (ptr to value)

  # Set arg1 (rdi=&dest)
  mov  rcx, [r14 + 8*2]    # arr->count
  imul rcx, rdx            # rcx = arr->count * arr->elem_size
  mov  rdi, [r14 + 8*0]    # arr->ptr
  add  rdi, rcx            # rdi=(arr->ptr + (arr->count * arr->elem_size))

  call memcpy@PLT

  # Update arr->count (++)
  mov rcx, QWORD PTR [r14 + 8*2]
  add rcx, 1
  mov QWORD PTR [r14 + 8*2], rcx

  xor rax, rax      # SUCCESS
  jmp .ret_block

.init_first:
  mov rax, -5

.ret_block:
  pop r15
  pop r14
  leave
  ret
