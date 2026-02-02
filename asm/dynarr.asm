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
  test rcx, rcx                       # arr->capacity != 0
  jnz  .already_init

# if (elem_size == 0 || cap == 0)
  test rsi, rsi        # elem_size == 0
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
  mov eax, -1
  jmp .ret_block

.invalid_sizes:
  mov eax, -2
  jmp .ret_block

.sizemax_overflow:
  mov eax, -3
  jmp .ret_block

.malloc_failed:
  mov eax, -4
  jmp .ret_block

.ret_block:
  leave
  ret


.global extend
.type extend, @function

# Function Parameters
#   rdi=&arr (pointer to the dynamic array struct)
#   rsi=add_bytes (extra bytes required, size_t)
extend:
  push rbp          # preserve old base pointer
  mov  rbp, rsp     # setup new base-ptr for current procedure
  push r12
  push r13

  test rdi, rdi       # !arr
  jz   .init_first

  # Even though arr->ptr is required in the two ending regions, it's far, which is why I am not using a callee-saved register.
  mov  rcx, QWORD PTR [rdi + 8*0]    # arr->ptr
  test rcx, rcx            # !arr->ptr

  # Repurposing rcx for arr->capacity
  mov  rcx, QWORD PTR [rdi + 8*3]    # arr->capacity
  test rcx, rcx                      # !arr->capacity
  jz   .init_first

  mov  r10, QWORD PTR [rdi + 8*2]     # arr->count
  add  r10, rsi                       # arr->count+add_bytes (becomes `total`, later)
  cmp  r10, rcx     # (arr->count+add_bytes <= arr->capacity)
  jb .success

# Now we need space for two variables: (total, cap)
#   `total` is already computed in r10, and rcx has arr->capacity.
#   No new register required.
#   rcx undergoes changes (cap *= 2) and the original arr->capacity is accessible at [rdi + 8*3]; Memory here is more authoritative.

# while (cap < total) cap *= 2
.inc_cap:
  # We are doing updation first because the condition is checked for the first time outside the loop already.
  # This is basically while loop changed to a do-while loop: `do { cap *= 2 } while ( cap < total);`
  shl rcx, 1    # cap *= 2
  cmp rcx, r10
  jb .inc_cap

# To call realloc, we've to override rdi and rsi, which have the params passed to the `extend` procedure.
# We need to preserve them to callee-saved registers. add_bytes is not used in anymore, so we only need to preserve rdi.
# Another thing we need to save is rcx which has the updated capacity, because rcx is a caller-saved register and extend becomes a caller as soon as it calls realloc.
.realloc:
  mov r13, rdi    # r13 = &arr
  mov r12, rcx    # r12 = new cap

  # Arg2 (rsi=cap*elem_size)
  mov  rsi, QWORD PTR [rdi + 8*1]    # rsi = arr->elem_size
  imul rsi, rcx            # rsi = arr->elem_size*cap   (rcx=new computed capacity)

  # Arg1 (rdi=arr->ptr)
  mov  rdi, QWORD PTR [rdi + 8*0]    # rdi = &arr->ptr

  call realloc@PLT
  test rax, rax
  jz   .realloc_failed

  mov QWORD PTR [r13 + 8*0], rax    # arr->ptr = tmp
  mov QWORD PTR [r13 + 8*3], r12    # arr->capacity = cap
  jmp .success

.init_first:
  mov eax, -5
  jmp .ret_block

.realloc_failed:
  mov eax, -6
  jmp .ret_block

.success:
  xor eax, eax

.ret_block:
  # Release memory in opposite order
  pop r13
  pop r12
  leave
  ret


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

  # arr->ptr is only active in this region, so no long lifetime
  mov  rcx, QWORD PTR [rdi + 8*0]     #  arr->ptr
  test rcx, rcx                       # !arr->ptr
  jz   .init_first

  test rsi, rsi     # !value
  jz   .invalid_pushreq

# Note: Earlier there was an if block which decided whether extend should be called. I've removed it because the same check happens inside extend. It doesn't make sense.

# extend takes 2 argument (&arr, add_bytes)
#   Since we are only pushing one element add_bytes (rsi) would be 1.
#   Although rdi is already set for pushOne, we still need to preserve it as it is a caller-saved register and pushOne will become a caller as-soon-as it calls extend.
#   rsi needs preservation too.
  mov  r14, rdi    # preserve rdi (&arr)
  mov  r15, rsi    # preserve rsi (&value_to_push)

  # Arg2 (rsi=1)
  mov  rsi, 1

  call extend     # extend(arr, 1)
  test eax, eax
  jnz  .ret_block     # No need to set rax as it is already set with appropriate return value

# Now comes memcpy, which takes 3 args (dest, src, bytes)
#   rsi=r15=&value     (src)
#   rdx=[r14 + 8*1]    (arr->elem_size)
#   rdi=dest needs computation.
#   To compute dest, we need: arr->ptr, arr->count and arr->elem_size
#   We've nothing active, so we have to load everything fresh from memory.

  # Arg3 (rsi=arr->elem_size)
  mov rdx, QWORD PTR [r14 + 8*1]     # arr->elem_size

  # Arg2 (rsi=&value)
  mov rsi, r15                       # (ptr to value)

  # Arg1 (rdi=&dest)
  mov  rcx, QWORD PTR [r14 + 8*2]    # arr->count
  imul rcx, rdx                      # rcx = arr->count * arr->elem_size
  mov  rdi, QWORD PTR [r14 + 8*0]    # arr->ptr
  add  rdi, rcx                      # rdi=(arr->ptr + (arr->count * arr->elem_size))

  call memcpy@PLT

  # Update arr->count (++)
  mov rcx, QWORD PTR [r14 + 8*2]
  add rcx, 1
  mov QWORD PTR [r14 + 8*2], rcx

  xor eax, eax      # SUCCESS
  jmp .ret_block

.init_first:
  mov eax, -5
  jmp .ret_block

.invalid_pushreq:
  mov eax, -7
  jmp .ret_block

.ret_block:
  pop r15
  pop r14
  leave
  ret


.global pushMany
.type pushMany, @function

# Function Parameters:
#   rdi=&arr (ptr to the dynarr struct)
#   rsi=&elements (ptr to the memory where the elements to be pushed reside, type:void)
#   rdx=count (number of elements, size_t)
pushMany:
  push rbp
  mov  rbp, rsp
  push r13
  push r14
  push r15
  sub  rsp, 8       # Dummy push to realign the stack at a 16 divisible boundary

  test rdi, rdi     # !arr
  jz   .init_first

  mov  rcx, QWORD PTR [rdi + 8*0]    # arr->ptr
  test rcx, rcx                      # !arr->ptr
  jz   .init_first

  test rsi, rsi             # !elements (arg2)
  jz   .invalid_pushreq

  test rdx, rdx             # count==0 (arg3)
  jz   .invalid_count

# Before we call extend, we must preserve rdi, rsi and rdx, as they're caller-saved registers and pushMany is about to become a caller
  mov r13, rdi    # &arr
  mov r14, rsi    # &elements
  mov r15, rdx    # count

  # Arg1 (rdi) already set.
  # Arg2 (rsi=rdx)
  mov  rsi, rdx      # count

  call extend
  test eax, eax      # res != SUCCESS
  jnz  .ret_block    # No need to set eax, the call itself sets it

# memcpy(dest, src, bytes)
#   It takes 3 args and none of them are loaded yet.
#   rsi=&elements (fixed)
#   We'll initialize rdx with arr->elem_size, this way, we can use it to compute dest and also bytes in memcpy

  # Arg3 (init only)
  mov rdx, QWORD PTR [r13 + 8*1]     # arr->elem_size

  # Arg2 (rsi=&elements)
  mov rsi, r14

  # Compute and Set arg1 (dest)
  mov  rcx, QWORD PTR [r13 + 8*2]    # arr->count
  imul rcx, rdx                      # arr->count * arr->elem_size
  mov  rdi, QWORD PTR [r13 + 8*0]    # arr->ptr
  add  rdi, rcx                      # rdi=dest

  # Finalize arg3 (rdx=arr->elem_size*count)
  imul rdx, r15

  call memcpy@PLT

  mov rcx, QWORD PTR [r13 + 8*2]    # rcx=arr->count (reload, as rcx is a caller-saved register which can be (will be) clobbered after a call within the procedure)
  add rcx, r15                      # rcx += count
  mov QWORD PTR [r13 + 8*2], rcx    # update

  xor eax, eax    # SUCCESS
  jmp .ret_block

.init_first:
  mov eax, -5
  jmp .ret_block

.invalid_pushreq:
  mov eax, -7
  jmp .ret_block

.ret_block:
# Release memory in opposite order of reservation
  add rsp, 8
  pop r15
  pop r14
  pop r13
  leave
  ret


.global boundcheck
.type boundcheck, @function

# Function Parameters:
#   rdi=lb   (lower bound)
#   rsi=ub   (upper bound)
#   rdx=idx  (idx)
boundcheck:
  push rbp
  mov  rbp, rsp

  cmp rdx, lb
  jb .zero       # idx < lb   (jb is for unsigned and jl is for signed)

  cmp rdx, rsi
  jae .zero      # idx > ub   (jae is for unsigned and jge is for signed)

  mov eax, 1
  jmp .ret_block

.zero:
  xor eax, rax

.ret_block:
  leave
  ret


.global getelement
.type getelement, @function

# Function Parameters:
#   rdi=&arr (ptr to the dynarr struct)
#   rsi=idx  (idx, size_t)
getelement:
  push rbp
  mov  rbp, rsp
  push r14
  push r15

  test rdi, rdi     # !arr
  jz   .null_ret

  # Although the procedure is small and arr->ptr is active in the 3rd (last) region, saving in callee-saved register and loading from memory seem almost the same.
  mov  rcx, QWORD PTR [rdi + 8*0]    #  arr->ptr
  test rcx, rcx                      # !arr->ptr
  jz   .null_ret

# boundcheck; Preserve rdi and rsi before
  mov r14, rdi
  mov r15, rsi

  # Arg3 (rdx=idx)
  mov rdx, rsi

  # Arg2 (rsi=arr->count)
  mov rsi, QWORD PTR [rdi + 8*2]

  # Arg1 (rdi=0)
  xor rdi, rdi      # not rdi because numbers are int by default, unless stated otherwise (integer literal suffixes), but we need rdi because boundcheck expects lb is a size_t value

  call boundcheck
  test eax, eax
  jz   .null_ret    # NULL

  # Calculate the ptr_to_idx
  mov  rcx, QWORD PTR [r14 + 8*1]    # arr->elem_size
  imul rcx, r15                      # rcx = idx * arr->elem_size
  mov  rax, QWORD PTR [r14 + 8*0]    # arr->ptr
  add  rax, rcx
  jmp  .ret_block

.null_ret:
  xor rax, rax      # NULL

.ret_block:
  pop r15
  pop r14
  leave
  ret


.global isempty
.type isempty, @function

# Function Parameters:
#   rdi=&arr
isempty:
  push rbp
  mov  rbp, rsp

  mov  rcx, QWORD PTR [rdi + 8*2]    # arr->count
  test rcx, rcx                      # !arr->count
  jz   .empty

  xor  eax, eax    # 0 for allocated
  jmp  .ret_block

.empty:
  mov eax, 1       # 1 for empty

.ret_block:
  leave
  ret


.global setidx
.type setidx, @function

# Function Parameters:
#   rdi= &arr
#   rsi= &value_to_set
#   rdx= idx
setidx:
  push rbp
  mov  rbp, rsp
  push r13
  push r14
  push r15
  sub  rsp, 8       # Dummy memory for rsp alignment

  test rdi, rdi     # !arr
  jz   .init_first

  mov  rcx, QWORD PTR [rdi + 8*0]    # arr->ptr
  test rcx, RCX                      # !arr->ptr
  jz   .init_first

  test rsi, rsi                      # !value
  jz   .invalid_pushreq

  mov  rcx, QWORD PTR [rdi + 8*2]    # arr->count
  test rcx, rcx                      # !arr->count
  jz   .init_first

# boundcheck; preserve rdi, rsi, rdx
  mov r13, rdi
  mov r14, rsi
  mov r15, rdx
# I prefer numbered registers (r12 - r15) because of less overhead compared to alphabetical once.

  # Arg3 (rdx=idx) already set.
  # Arg2 (rsi=arr->count)
  mov rsi, QWORD PTR [rdi + 8*2]

  # Arg1 (rdi=0)
  xor rdi, rdi    # Although normal digits are considered ints unless stated otherwise, we can't use edi here because boundcheck expects a size_t value. Although it doesn't affect because 0 on zext or sext remains 0. But it is wrong principle-wise. If the callee expects size_t, pass size_t only. Because if -1 was passed, we know we are done because zero extension is implicit and we are gonna have 4.29b+ instead of -1. And I need to follow the principles.

  call boundcheck
  test eax, eax
  jz   .invalid_idx

# memcpy
  # Arg3 (rdx=arr->elem_size)
  mov rdx, QWORD PTR [r13 + 8*1]    # arr->elem_size

  # Arg2 (rsi=&value)
  mov rsi, r14

  # Arg1 (rdi=dest)
  imul r15, rdx                      # r15=idx*arr->elem_size
  mov  rdi, QWORD PTR [r13 + 8*0]    # arr->ptr
  add  rdi, r15                      # rdi += r15

  call memcpy@PLT
  xor  eax, eax   # SUCCESS
  jmp .ret_block

.init_first:
  mov eax, -5
  jmp .ret_block

.invalid_pushreq:
  mov eax, -7
  jmp .ret_block

.invalid_idx:
  mov eax, -8
  jmp .ret_block

.ret_block:
  add rsp, 8
  pop r15
  pop r14
  pop r13
  leave
  ret


.global mergedyn2dyn
.type mergedyn2dyn, @function

# Function Parameters:
#   rdi=&src
#   rsi=&dest
mergedyn2dyn:
  push rbp
  mov  rbp, rsp
  push r14
  push r15

  test rdi, rdi    # !src
  jz   .init_first

  mov  rcx, QWORD PTR [rdi + 8*0]
  test rcx, rcx    # !src->ptr
  jz   .init_first

  test rsi, rsi    # !dest
  jz   .init_first

  mov  rcx, QWORD PTR [rsi + 8*0]
  test rcx, rcx    # !dest->ptr
  jz   .init_first

  # Even though these values are active in the 3rd region, I'd prefer loading from memory
  mov rcx, QWORD PTR [rdi + 8*1]    # src->elem_size
  mov r8,  QWORD PTR [rsi + 8*1]    # dest->elem_size
  cmp rcx, r8
  jne .types_dont_match

# extend; preserve rdi, rsi
  mov r14, rdi
  mov r15, rsi

  # Arg1 (rdi=dest=rsi)
  mov rdi, rsi

  # Arg2 (rsi=src->count)
  mov rsi, QWORD PTR [r14 + 8*2]

  call extend
  test eax, eax
  jnz  .ret_block

# memcpy: 3 args (dptr, src->ptr, bytes): all fresh loads
  # Arg2 (rsi=src->ptr)
  mov rsi, QWORD PTR [r14 + 8*0]

  # Arg3 (rdx=src->count * src->elem_size)
  mov  rdx, QWORD PTR [r14 + 8*2]    # src->count
  imul rdx, QWORD PTR [r14 + 8*1]    # rdx = src->count * src->elem_size

  # Arg1 (rdi=dptr)
  mov  rcx, QWORD PTR [r15 + 8*2]    # dest->count
  imul rcx, QWORD ptr [r15 + 8*1]    # dest->count * dest->elem_size
  mov  rdi, QWORD PTR [r15 + 8*0]    # base
  add  rdi, rcx                      # base + offset

  call memcpy@PLT

  mov rcx, QWORD PTR [r15 + 8*2]    # dest->count
  add rcx, QWORD PTR [r14 + 8*2]    # dest->count += src->count
  mov QWORD PTR [r15 + 8*2], rcx

  xor eax, eax    # SUCCESS
  jmp .ret_block

.init_first:
  mov eax, -5
  jmp .ret_block

.types_dont_match:
  mov eax, -9

.ret_block:
  pop r15
  pop r14
  leave
  ret


.global export2stack
.type export2stack, @function

# Function Parameters:
#   rdi=&dynarr
#   rsi=**stackarr
export2stack:
  push rbp
  mov  rbp, rsp

  test rdi, rdi    # !dynarr
  jz   .init_first

  mov  rcx, QWORD PTR [rdi + 8*0]
  test rcx, rcx    # !dynarr->ptr
  jz   .init_first

# memcpy; no need to save anything because nothing exists beyond this memcpy call.
  # Arg2 (rsi=dynarr->ptr)
  mov rsi, QWORD PTR [rdi + 8*0]

  # Arg3 (rdx=bytes)
  mov  rcx, QWORD PTR [rdi + 8*1]    # dynarr->elem_size
  imul rcx, QWORD PTR [rdi + 8*2]    # dynarr->count

  # Arg1 (rdi=*stackarr)
  mov rdi, QWORD PTR [rsi]           # I am unsure about this though!

  call memcpy@PLT

  xor eax, eax
  jmp .ret_block

.init_first:
  mov eax, -5

.ret_block:
  leave
  ret


.global insertidx
.type insertidx, @function

# Function Parameters
#   rdi = &arr
#   rsi = &value
#   rdx = idx
insertidx:
  push rbp
  mov  rbp, rsp
  push r13
  push r14
  push r15
  sub  rsp, 8

  test rdi, rdi       # !arr
  jz   .init_first

  mov  rcx, QWORD PTR [rdi + 8*0]    # arr->ptr
  test rcx, rcx                      # !arr->ptr
  jz   .init_first

  test rsi, rsi                      # !value
  jz   .invalid_pushreq

# boundcheck; preserve rdi, rsi and rdx
  mov r13, rdi
  mov r14, rsi
  mov r15, rdx

  # Arg3 (rdx=idx) already set
  # Arg2 (rsi=arr->count)
  mov rsi, QWORD PTR [rdi + 8*2]

  # Arg1 (rdi=0)
  xor rdi, rdi

  call boundcheck
  test eax, eax
  jz   .invalid_idx

# extend
  mov rdi, r13
  mov rsi, 1

  call extend
  test eax, eax
  jnz  .ret_block

# memmove(dest, src, idx)
# Since arr->elem_size is used frequently, but only before memmove, I'll assign r8 to it. No need for callee-saved register.
  mov r8, [r13 + 8*1]

  # Compute and set arg1 (rdi=dest)
  mov  rcx, r15                      # idx
  add  rcx, 1                        # idx+1
  imul rcx, r8                       # (idx+1)*arr->elem_size
  mov  rdi, QWORD PTR [r13 + 8*0]    # base
  add  rdi, rcx                      # base + offset

  # Compute and set arg2 (rsi=src)
  mov  rcx, r15                      # idx
  imul rcx, r8                       # rcx=idx*elem_size
  mov  rsi, QWORD PTR [r13 + 8*0]    # base
  add  rsi, rcx                      # base + offset

  # Compute and set arg3 (rdx=bytes)
  mov  rcx, QWORD PTR [r13 + 8*2]    # arr->count
  sub  rcx, r15                      # rcx = rcx - idx
  imul rcx, r8                       # rcx = rcx*elem_size

  call memmove@PLT

# setidx(&ar, &value, idx)
  mov rdi, r13
  mov rsi, r14
  mov rdx, r15

  call setidx
  test eax, eax
  jnz  .ret_block

  add QWORD PTR [r13 + 8*2], 1    # arr->count++
  xor eax, eax    # SUCCESS
  jmp .ret_block

.init_first:
  mov eax, -5
  jmp .ret_block

.invalid_pushreq:
  mov eax, -7
  jmp .ret_block

.invalid_idx:
  mov eax, -8
  jmp .ret_block

.ret_block:
  add rsp, 8
  pop r15
  pop r14
  pop r13
  leave
  ret


.global removeidx
.type removeidx, @function

# Function Parameters:
#   rdi=&arr
#   rsi=idx
removeidx:
  push rbp
  mov  rbp, rsp
  push r13
  push r14

  test rdi, rdi
  jz   .init_first

  mov  rcx, [rdi + 8*0]   # arr->ptr
  test rcx, rcx           # !arr->ptr
  jz   .init_first

# boundcheck; preserve rdi, rsi and rdx
  mov r13, rdi
  mov r14, rsi

  # Arg3 (rdx=idx)
  mov rdx, rsi

  # Arg2 (rsi=arr->count)
  mov rsi, [rdi + 8*2]

  # Arg1 (rdi=0)
  xor rdi, rdi

  call boundcheck
  test eax, eax
  jz   .invalid_idx

# memmove(dest, src, bytes)
  mov r8, QWORD PTR [rdi + 8*1]    # arr->elem_size

  # Arg1 (rdi=dest)
  mov  rcx, r14                      # idx
  imul rcx, r8                       # rcx=idx*elem_size
  mov  rdi, QWORD PTR [r13 + 8*0]    # base
  add  rdi, rcx                      # base + offset

  # Arg2 (rsi=src)
  mov  rcx, r14                      # idx
  add  rcx, 1                        # idx+1
  imul rcx, r8                       # rcx=(idx+1)*elem_size
  mov  rsi, QWORD PTR [r13 + 8*0]    # base
  add  rsi, rcx                      # base + offset

  # Arg3 (rdx=bytes)
  mov  rdx, QWORD PTR [r13 + 8*2]    # arr->count
  sub  rdx, r14                      # arr->count - idx
  sub  rdx, 1                        # arr->count - idx - 1
  imul rdx, r8                       # bytes=rcx*elem_size

  call memmove@PLT
  sub QWORD PTR [r13 + 8*2], 1       # arr->count--

  xor eax, eax    # SUCCESS
  jmp .ret_block

.init_first:
  mov eax, -5
  jmp .ret_block

.invalid_idx:
  mov eax, -8
  jmp .ret_block

.ret_block:
  pop r14
  pop r13
  leave
  ret


.global clearArr
.type clearArr, @function

# Funciton Parameters:
#   rdi=&arr
clearArr:
  push rbp
  mov  rbp, rsp

  test rdi, rdi
  jz   .init_first

  mov  rcx, QWORD PTR [rdi + 8*0]
  test rcx, rcx
  jz   .init_first

  mov QWORD PTR [rdi + 8*0], 0    # arr->ptr
  mov QWORD PTR [rdi + 8*2], 0    # arr->count
  mov QWORD PTR [rdi + 8*1], 0    # arr->elem_size

  xor eax, eax
  jmp .ret_block

.init_first:
  mov eax, -5

.ret_block:
  leave
  ret


.global freeArr
.type freeArr, @function

# Function Parameters:
#   rdi=&arr
freeArr:
  push rbp
  mov  rbp, rsp
  push rbx
  sub rsp, 8

  test rdi, rdi
  jz   .init_first

  mov  rcx, QWORD PTR [rdi + 8*0]
  test rcx, rcx
  jz   .init_first

  mov  rbx, rdi    # PRESERVE rdi
  call free@PLT

  mov QWORD PTR [rdi + 8*0], 0
  mov QWORD PTR [rdi + 8*1], 0
  mov QWORD PTR [rdi + 8*2], 0
  mov QWORD PTR [rdi + 8*3], 0

  xor eax, eax
  jmp .ret_block

.init_first:
  mov eax, -5

.ret_block:
  add rsp, 8
  pop rbx
  leave
  ret

