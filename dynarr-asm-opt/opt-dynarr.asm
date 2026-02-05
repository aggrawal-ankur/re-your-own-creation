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
  push r13
  push r14
  push r15
  # Since rbp is not used, only 3 registers are required to be pushed

  mov  eax, -1                 # Hoist return outside
  mov  rcx, QWORD PTR [rdi]    # arr->ptr
  test rcx, rcx                # arr->ptr != 0
  jnz  .ret_block_p1

  mov  eax, -2
  test rsi, rsi         # (elem_size == 0)
  jz   .ret_block_p1

  test rdx, rdx         # if (cap == 0)
  jz   .ret_block_p1

# if (cap > SIZE_MAX/elem_size) return SIZEMAX_OVERFLOW;
  mov  r15, rdx    # preserve rdx (cap) in r15 as mul will clobber rdx to store 64-127 bits of the result (overflow)
  mov  rax, rdx    # rax = cap
  mul  rsi         # (rax * rsi) == (cap * elem_size)  Result => rdx:rax {rdx:64-127 bits, rax:0-63 bits}
  test rdx, rdx    # Check if result overflowed to rdx
  jnz  .sizemax_overflow    # Jump if rdx is non-zero

# malloc; preserve rdi and rsi
  mov r13, rdi
  mov r14, rsi

  # Arg1 malloc (rdi=cap*elem_size=rax)
  mov  rdi, rax

  call malloc@PLT
  test rax, rax    # NULL check on the pointer returned by malloc
  jz   .malloc_failed

  mov QWORD PTR   [r13], rax    # arr->ptr = rax (malloc's return value)
  mov QWORD PTR  8[r13], r14    # arr->elem_size (rsi)
  mov QWORD PTR 16[r13], 0      # arr->count     (initialize with 0)
  mov QWORD PTR 24[r13], r15    # arr->capacity  (rcx)

  xor rax, rax    # rax=SUCCESS (0)
  jmp .ret_block_p1

# SIZEMAX_OVERFLOW can't be hoisted as mul operates on rax and stores the quotient in it.
.sizemax_overflow:
  mov eax, -3
  jmp .ret_block_p1

# can't be hoisted because malloc clobbers eax, so there is not point in doing that, unless we decouple return with a different register like ecx and then mov ecx into eax before returning, the way gcc does it at -O1.
.malloc_failed:
  mov eax, -4
  jmp .ret_block_p1

.ret_block_p1:
  pop r15
  pop r14
  pop r13
  ret


.global extend
.type extend, @function

# Function Parameters
#   rdi=&arr (pointer to the dynamic array struct)
#   rsi=add_bytes (extra bytes required, size_t)
extend:
  push r12
  push r13
  sub  rsp, 8

  mov eax, -5
  test rdi, rdi    # !arr
  jz   .ret_block_p2

  # Even though arr->ptr is required in the two ending regions, it's far, which is why I am not using a callee-saved register.
  mov  rcx, QWORD PTR [rdi]    # arr->ptr
  test rcx, rcx                # !arr->ptr
  jz   .ret_block_p2

  # Repurposing rcx for arr->capacity
  mov rcx, QWORD PTR 24[rdi]    # arr->capacity
  mov r10, QWORD PTR 16[rdi]    # arr->count
  add r10, rsi                  # arr->count+add_bytes (becomes `total`, later)
  xor eax, eax    # return hoisted
  cmp r10, rcx                  # (arr->count+add_bytes <= arr->capacity)
  jbe .ret_block_p2

# Now we need space for two variables: (total, cap)
#   `total` is already computed in r10, and rcx has arr->capacity.
#   No new register required.
#   rcx undergoes changes (cap *= 2) and the original arr->capacity is accessible at 24[rdi]; Memory here is more authoritative.

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
  mov  rsi, QWORD PTR 8[rdi]    # rsi = arr->elem_size
  imul rsi, rcx                 # rsi = arr->elem_size*cap

  # Arg1 (rdi=arr->ptr)
  mov rdi, QWORD PTR [rdi]

  call realloc@PLT
  test rax, rax
  jz   .realloc_failed

  mov QWORD PTR   [r13], rax    # arr->ptr = tmp
  mov QWORD PTR 24[r13], r12    # arr->capacity = cap

  xor eax, eax
  jmp .ret_block_p2

.realloc_failed:
  mov eax, -6

.ret_block_p2:
  # Release memory in opposite order
  add rsp, 8
  pop r13
  pop r12
  ret


.global pushOne
.type pushOne, @function

# Function Parameters:
#   rdi=&arr   (ptr to the dynamic array struct)
#   rsi=&value (ptr to the value to be pushed in the arr->ptr, type:void)
pushOne:
  push r14
  push r15
  sub  rsp, 8

  mov eax, -5
  test rdi, rdi      # !arr
  jz .ret_block_p2

  # arr->ptr is only active in this region, so no long lifetime
  mov  rcx, QWORD PTR [rdi]    #  arr->ptr
  test rcx, rcx                # !arr->ptr
  jz   .ret_block_p2

  mov eax, -7
  test rsi, rsi    # !value
  jz   .ret_block_p2

# Note: Earlier there was an if block which decided whether extend should be called. I've removed it because the same check happens inside extend. It doesn't make sense.

# extend takes 2 argument (&arr, add_bytes)
#   Since we are only pushing one element add_bytes (rsi) would be 1.
#   Although rdi is already set for pushOne, we still need to preserve it as it is a caller-saved register and pushOne will become a caller as-soon-as it calls extend.
#   rsi needs preservation too.
  mov  r14, rdi    # preserve rdi (&arr)
  mov  r15, rsi    # preserve rsi (&value_to_push)

  # Arg2 (rsi=1)
  mov  rsi, 1

  call extend      # extend(arr, 1)
  test eax, eax
  jnz  .ret_block_p3  # No need to set rax as it is already set with appropriate return value

# Now comes memcpy, which takes 3 args (dest, src, bytes)
#   rsi=r15=&value (src)
#   rdx=8[r14] (arr->elem_size)
#   rdi=dest needs computation.
#   To compute dest, we need: arr->ptr, arr->count and arr->elem_size
#   We've nothing active, so we have to load everything fresh from memory.

  # Arg3 (rsi=arr->elem_size)
  mov rdx, QWORD PTR 8[r14]    # arr->elem_size

  # Arg2 (rsi=&value)
  mov rsi, r15                 # (ptr to value)

  # Arg1 (rdi=&dest)
  mov  rcx, QWORD PTR 16[r14]    # arr->count
  imul rcx, rdx                  # rcx = arr->count * arr->elem_size
  mov  rdi, QWORD PTR   [r14]    # arr->ptr
  add  rdi, rcx                  # rdi=(arr->ptr + (arr->count * arr->elem_size))

  call memcpy@PLT

  # Update arr->count (++)
  add QWORD PTR 16[r14], 1

  xor eax, eax      # SUCCESS
  jmp .ret_block_p3

.ret_block_p3:
  add rsp, 8
  pop r15
  pop r14
  ret


.global pushMany
.type pushMany, @function

# Function Parameters:
#   rdi=&arr (ptr to the dynarr struct)
#   rsi=&elements (ptr to the memory where the elements to be pushed reside, type:void)
#   rdx=count (number of elements, size_t)
pushMany:
  push r13
  push r14
  push r15

  mov  eax, -5
  test rdi, rdi    # !arr
  jz   .ret_block_p4

  mov  rcx, QWORD PTR [rdi]    # arr->ptr
  test rcx, rcx                # !arr->ptr
  jz   .ret_block_p4

  mov  rax, -7
  test rsi, rsi                # !elements (arg2)
  jz   .ret_block_p4

  test rdx, rdx                # count==0 (arg3)
  jz   .ret_block_p4

# Before we call extend, we must preserve rdi, rsi and rdx, as they're caller-saved registers and pushMany is about to become a caller
  mov r13, rdi    # &arr
  mov r14, rsi    # &elements
  mov r15, rdx    # count

  # Arg1 (rdi) already set.
  # Arg2 (rsi=rdx)
  mov rsi, rdx    # count

  call extend
  test eax, eax         # res != SUCCESS
  jnz  .ret_block_p4    # No need to set eax, the call itself sets it

# memcpy(dest, src, bytes)
#   It takes 3 args and none of them are loaded yet.
#   rsi=&elements (fixed)
#   We'll initialize rdx with arr->elem_size, this way, we can use it to compute dest and also bytes in memcpy

  # Arg3 (init only)
  mov rdx, QWORD PTR 8[r13]    # arr->elem_size

  # Arg2 (rsi=&elements)
  mov rsi, r14

  # Compute and Set arg1 (dest)
  mov  rcx, QWORD PTR 16[r13]    # arr->count
  imul rcx, rdx                  # arr->count * arr->elem_size
  mov  rdi, QWORD PTR [r13]      # arr->ptr
  add  rdi, rcx                  # rdi=dest

  # Finalize arg3 (rdx=arr->elem_size*count)
  imul rdx, r15
  call memcpy@PLT

  mov rcx, QWORD PTR 16[r13]    # rcx=arr->count (reload, as rcx is a caller-saved register which can be (will be) clobbered after a call within the procedure)
  add rcx, r15                  # rcx += count
  mov QWORD PTR 16[r13], rcx    # update

  xor eax, eax    # SUCCESS
  jmp .ret_block_p4

.ret_block_p4:
# Release memory in opposite order of reservation
  pop r15
  pop r14
  pop r13
  ret


.global boundcheck
.type boundcheck, @function

# Function Parameters:
#   rdi=lb   (lower bound)
#   rsi=ub   (upper bound)
#   rdx=idx  (idx)
boundcheck:
  xor eax, eax    # hoist return

  cmp rdx, rdi
  jb .ret_block_p5       # idx < lb   (jb is for unsigned and jl is for signed)

  cmp rdx, rsi
  jae .ret_block_p5      # idx > ub   (jae is for unsigned and jge is for signed)

  mov eax, 1

.ret_block_p5:
  ret


.global getelement
.type getelement, @function

# Function Parameters:
#   rdi=&arr (ptr to the dynarr struct)
#   rsi=idx  (idx, size_t)
getelement:
  push r14
  push r15
  sub rsp, 8

  test rdi, rdi    # !arr
  jz   .null_ret

  # Although the procedure is small and arr->ptr is active in the 3rd (last) region, saving in callee-saved register and loading from memory seem almost the same.
  mov  rcx, QWORD PTR [rdi]    #  arr->ptr
  test rcx, rcx                # !arr->ptr
  jz   .null_ret

# boundcheck; Preserve rdi and rsi before
  mov r14, rdi
  mov r15, rsi

  # Arg3 (rdx=idx)
  mov rdx, rsi

  # Arg2 (rsi=arr->count)
  mov rsi, QWORD PTR 16[rdi]

  # Arg1 (rdi=0)
  xor rdi, rdi      # not rdi because numbers are int by default, unless stated otherwise (integer literal suffixes), but we need rdi because boundcheck expects lb is a size_t value

  call boundcheck
  test eax, eax
  jz   .null_ret    # NULL

  # Calculate the ptr_to_idx
  mov  rcx, QWORD PTR 8[r14]    # arr->elem_size
  imul rcx, r15                 # rcx = arr->elem_size * idx
  mov  rax, QWORD PTR  [r14]    # arr->ptr
  add  rax, rcx
  jmp  .ret_block_p6

# This can't be hoisted as the result is literally sent in eax
.null_ret:
  xor rax, rax    # NULL

.ret_block_p6:
  add rsp, 8
  pop r15
  pop r14
  ret


.global isempty
.type isempty, @function

# Function Parameters:
#   rdi=&arr
isempty:
  mov  eax, 1
  mov  rcx, QWORD PTR 16[rdi]    # arr->count
  test rcx, rcx                  # !arr->count
  jz   .ret_block_p7

  xor  eax, eax       # 0 for allocated

.ret_block_p7:
  ret


.global setidx
.type setidx, @function

# Function Parameters:
#   rdi= &arr
#   rsi= &value_to_set
#   rdx= idx
setidx:
  push r13
  push r14
  push r15

  mov eax, -5
  test rdi, rdi    # !arr
  jz   .ret_block_p8

  mov  rcx, QWORD PTR [rdi]      # arr->ptr
  test rcx, rcx                  # !arr->ptr
  jz   .ret_block_p8

  test rsi, rsi                  # !value
  jz   .invalid_pushreq_p8

# boundcheck; preserve rdi, rsi, rdx
  mov r13, rdi
  mov r14, rsi
  mov r15, rdx
# I prefer numbered registers (r12 - r15) because of less mental overhead compared to alphabetical ones.

  # Arg3 (rdx=idx) already set.
  # Arg2 (rsi=arr->count)
  mov rsi, QWORD PTR 16[rdi]

  # Arg1 (rdi=0)
  xor rdi, rdi    # Although normal digits are considered ints unless stated otherwise, we can't use edi here because boundcheck expects a size_t value. Although it doesn't affect because 0 on zext or sext remains 0. But it is wrong principle-wise. If the callee expects size_t, pass size_t only. Because if -1 was passed, we know we are done because zero extension is implicit and we are gonna have 4.29b+ instead of -1. And I need to follow the principles.

  call boundcheck
  test eax, eax
  jz   .invalid_idx_p8

# memcpy
  # Arg3 (rdx=arr->elem_size)
  mov rdx, QWORD PTR 8[r13]    # arr->elem_size

  # Arg2 (rsi=&value)
  mov rsi, r14

  # Arg1 (rdi=dest)
  imul r15, rdx                # r15=idx*arr->elem_size
  mov  rdi, QWORD PTR [r13]    # arr->ptr
  add  rdi, r15                # rdi += r15

  call memcpy@PLT
  xor  eax, eax    # SUCCESS
  jmp .ret_block_p8

# I can't tell the reason yet, but I am not hoisting it.
.invalid_pushreq_p8:
  mov eax, -7
  jmp .ret_block_p8

# This can't hoisted as eax has the return value from boundcheck
.invalid_idx_p8:
  mov eax, -8
  jmp .ret_block_p8

.ret_block_p8:
  pop r15
  pop r14
  pop r13
  ret


.global mergedyn2dyn
.type mergedyn2dyn, @function

# Function Parameters:
#   rdi=&src
#   rsi=&dest
mergedyn2dyn:
  push r14
  push r15
  sub  rsp, 8

  mov  eax, -5
  test rdi, rdi    # !src
  jz   .ret_block_p9

  mov  rcx, QWORD PTR [rdi]
  test rcx, rcx    # !src->ptr
  jz   .ret_block_p9

  test rsi, rsi    # !dest
  jz   .ret_block_p9

  mov  rcx, QWORD PTR [rsi]
  test rcx, rcx    # !dest->ptr
  jz   .ret_block_p9

  # Even though these values are active in the 3rd region, I'd prefer loading from memory
  mov rcx, QWORD PTR 8[rdi]    # src->elem_size
  mov r8,  QWORD PTR 8[rsi]    # dest->elem_size
  cmp rcx, r8
  jne .types_dont_match

# extend; preserve rdi, rsi
  mov r14, rdi
  mov r15, rsi

  # Arg1 (rdi=dest=rsi)
  mov rdi, rsi

  # Arg2 (rsi=src->count)
  mov rsi, QWORD PTR 16[r14]

  call extend
  test eax, eax
  jnz  .ret_block_p9    # (ret: NULL)

# memcpy: 3 args (dptr, src->ptr, bytes): all fresh loads
  # Arg2 (rsi=src->ptr)
  mov rsi, QWORD PTR [r14]

  # Arg3 (rdx=src->count * src->elem_size)
  mov  rdx, QWORD PTR 16[r14]    # src->count
  imul rdx, QWORD PTR  8[r14]    # rdx = src->count * src->elem_size

  # Arg1 (rdi=dptr)
  mov  rcx, QWORD PTR 16[r15]    # dest->count
  imul rcx, QWORD ptr  8[r15]    # dest->count * dest->elem_size
  mov  rdi, QWORD PTR   [r15]    # base
  add  rdi, rcx                  # base + offset

  call memcpy@PLT

  mov rcx, QWORD PTR 16[r15]    # dest->count
  add rcx, QWORD PTR 16[r14]    # dest->count += src->count
  mov QWORD PTR 16[r15], rcx

  xor eax, eax    # SUCCESS
  jmp .ret_block_p9

.types_dont_match:
  mov eax, -9

.ret_block_p9:
  add rsp, 8
  pop r15
  pop r14
  ret


.global export2stack
.type export2stack, @function

# Function Parameters:
#   rdi=&dynarr
#   rsi=*stackarr
export2stack:
  mov  eax, -5
  test rdi, rdi    # !dynarr
  jz   .ret_block_p10

  mov  rcx, QWORD PTR [rdi]
  test rcx, rcx    # !dynarr->ptr
  jz   .ret_block_p10

# memcpy; no need to save anything because nothing exists beyond this memcpy call.
  # Arg3 (rdx=bytes)
  mov  rdx, QWORD PTR  8[rdi]    # dynarr->elem_size
  imul rdx, QWORD PTR 16[rdi]    # dynarr->count

  # Arg2 (rsi=dynarr->ptr)
  mov rcx, rsi                   # Preserve rsi as rdi needs it
  mov rsi, QWORD PTR [rdi]

  # Arg1 (rdi=*stackarr)
  mov rdi, rcx

  call memcpy@PLT
  xor eax, eax

.ret_block_p10:
  ret


.global insertidx
.type insertidx, @function

# Function Parameters
#   rdi = &arr
#   rsi = &value
#   rdx = idx
insertidx:
  push r13
  push r14
  push r15

  mov  eax, -5
  test rdi, rdi    # !arr
  jz   .ret_block_p11

  mov  rcx, QWORD PTR [rdi]    # arr->ptr
  test rcx, rcx                # !arr->ptr
  jz   .ret_block_p11

  test rsi, rsi                # !value
  jz   .invalid_pushreq_p11

# boundcheck; preserve rdi, rsi and rdx
  mov r13, rdi
  mov r14, rsi
  mov r15, rdx

  # Arg3 (rdx=idx) already set
  # Arg2 (rsi=arr->count)
  mov rsi, QWORD PTR 16[rdi]

  # Arg1 (rdi=0)
  xor rdi, rdi

  call boundcheck
  test eax, eax
  jz   .invalid_idx_p11

# extend
  mov rdi, r13    # Arg1
  mov rsi, 1      # Arg2

  call extend
  test eax, eax
  jnz  .ret_block_p11

# memmove(dest, src, idx)
# Since arr->elem_size is used frequently, but only before memmove, I'll assign r8 to it. No need for callee-saved register.
  mov r8, 8[r13]

  # Compute and set arg1 (rdi=dest)
  mov  rcx, r15                  # idx
  add  rcx, 1                    # idx+1
  imul rcx, r8                   # (idx+1)*arr->elem_size
  mov  rdi, QWORD PTR [r13]      # base
  add  rdi, rcx                  # base + offset

  # Compute and set arg2 (rsi=src)
  mov  rcx, r15                  # idx
  imul rcx, r8                   # rcx=idx*elem_size
  mov  rsi, QWORD PTR [r13]      # base
  add  rsi, rcx                  # base + offset

  # Compute and set arg3 (rdx=bytes)
  mov  rcx, QWORD PTR 16[r13]    # arr->count
  sub  rcx, r15                  # rcx = rcx - idx
  imul rcx, r8                   # rcx = rcx*elem_size

  call memmove@PLT

# setidx(&ar, &value, idx)
  mov rdi, r13
  mov rsi, r14
  mov rdx, r15

  call setidx
  test eax, eax
  jnz  .ret_block_p11

  add QWORD PTR 16[r13], 1    # arr->count++
  xor eax, eax    # SUCCESS
  jmp .ret_block_p11

.invalid_pushreq_p11:
  mov eax, -7
  jmp .ret_block_p11

.invalid_idx_p11:
  mov eax, -8
  jmp .ret_block_p11

.ret_block_p11:
  pop r15
  pop r14
  pop r13
  ret


.global removeidx
.type removeidx, @function

# Function Parameters:
#   rdi=&arr
#   rsi=idx
removeidx:
  push r13
  push r14
  sub rsp, 8

  mov  eax, -5
  test rdi, rdi
  jz   .ret_block_p12

  mov  rcx, [rdi]    # arr->ptr
  test rcx, rcx      # !arr->ptr
  jz   .ret_block_p12

# boundcheck; preserve rdi and rsi
  mov r13, rdi
  mov r14, rsi

  # Arg3 (rdx=idx)
  mov rdx, rsi

  # Arg2 (rsi=arr->count)
  mov rsi, 16[rdi]

  # Arg1 (rdi=0)
  xor rdi, rdi

  call boundcheck
  test eax, eax
  jz   .invalid_idx_p12

# memmove(dest, src, bytes)
  mov r8, QWORD PTR 8[r13]    # arr->elem_size

  # Arg1 (rdi=dest)
  mov  rcx, r14               # idx
  imul rcx, r8                # rcx=idx*elem_size
  mov  rdi, QWORD PTR [r13]   # base
  add  rdi, rcx               # base + offset

  # Arg2 (rsi=src)
  mov  rcx, r14               # idx
  add  rcx, 1                 # idx+1
  imul rcx, r8                # rcx=(idx+1)*elem_size
  mov  rsi, QWORD PTR [r13]   # base
  add  rsi, rcx               # base + offset

  # Arg3 (rdx=bytes)
  mov  rdx, QWORD PTR 16[r13]    # arr->count
  sub  rdx, r14                  # arr->count - idx
  sub  rdx, 1                    # arr->count - idx - 1
  imul rdx, r8                   # bytes=rcx*elem_size

  call memmove@PLT
  sub QWORD PTR 16[r13], 1       # arr->count--

  xor eax, eax    # SUCCESS
  jmp .ret_block_p12

.invalid_idx_p12:
  mov eax, -8

.ret_block_p12:
  add rsp, 8
  pop r14
  pop r13
  ret


.global clearArr
.type clearArr, @function

# Funciton Parameters:
#   rdi=&arr
clearArr:
  mov  eax, -5
  test rdi, rdi
  jz   .ret_block_p13

  mov  rcx, QWORD PTR [rdi]
  test rcx, rcx
  jz   .ret_block_p13

  mov QWORD PTR [rdi], 0    # arr->ptr
  mov QWORD PTR 16[rdi], 0  # arr->count
  mov QWORD PTR 8[rdi], 0   # arr->elem_size

  xor eax, eax

.ret_block_p13:
  ret


.global freeArr
.type freeArr, @function

# Function Parameters:
#   rdi=&arr
freeArr:
  push rbx

  mov  eax, -5
  test rdi, rdi
  jz   .ret_block_p14

  mov  rcx, QWORD PTR [rdi]
  test rcx, rcx
  jz   .ret_block_p14

  mov  rbx, rdi    # PRESERVE rdi
  call free@PLT

  mov QWORD PTR   [rdi], 0
  mov QWORD PTR  8[rdi], 0
  mov QWORD PTR 16[rdi], 0
  mov QWORD PTR 24[rdi], 0

  xor eax, eax

.ret_block_p14:
  pop rbx
  ret

