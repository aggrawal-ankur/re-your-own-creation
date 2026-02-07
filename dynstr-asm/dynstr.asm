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


.global cmp2strs
.type cmp2strs, @function

# Function Parameters
#   rdi=str1 (const dynstr*)
#   rsi=str2 (const dynstr*)
#   rdx=sensitivity (int)
cmp2strs:
  push r13

  xor  eax, eax
  test rdi, rdi
  jz   .ret_block_p15_1

  mov  rcx, QWORD PTR [rdi]
  test rcx, rcx
  jz   .ret_block_p15_1

  test rsi, rsi
  jz   .ret_block_p15_1

  mov  rcx, QWORD PTR [rsi]
  test rcx, rcx
  jz   .ret_block_p15_1

  mov  rcx, QWORD PTR 8[rdi]
  mov  r10, QWORD PTR 8[rsi]
  test rcx, r10
  jnz  .strs_not_eq_p15_1

# Case sensitive (0)
  mov  rdx, QWORD PTR 8[rdi]    # Arg3 (rdx=str1->len)
  mov  rsi, QWORD PTR  [rsi]    # Arg2 (rsi=str2->data)
  mov  rdi, QWORD PTR  [rdi]    # Arg1 (rdi=str1->data)
  call memcmp@PLT
  test rax, rax
  jnz  .strs_not_eq_p15_1

  xor eax, eax
  jmp .ret_block_p15_1

# Case insensitive (1)
  # Since pushing registers is only required in case of insensitive check.
  # But for alignment purpose, we need to push one register at least, so only two registers are being pushed here.
  push r14    # tmp1[str1->len+1]
  push r15    # tmp2[str2->len+1]
  push rbp    # str1
  push rbx    # str2
  mov  rbp, rdi
  mov  rbx, rsi

  # VLA aligned-space calculation
  add rcx, r10    # total bytes required: (rcx, r10)
  add rcx, 2      # count for '\0'
  add rcx, 15     # (total + 15)
  and rcx, -16    # (total + 15) & ~15
  sub rsp, rcx

  mov r14, rsp                # &tmp1[str1->len+1]
  lea r15, [rsp + r10 + 1]    # &tmp2[str2->len+1]

# tolcase calls
  mov  rdi, QWORD PTR [rbp]    # Arg1 (rdi=str1->data)
  mov  rsi, r14                # Arg2 (rsi=tmp1)
  call tolcase
  test eax, eax
  jnz  .cmp_failed_p15

  mov  rdi, QWORD PTR [rbx]    # Arg1 (rdi=str2->data)
  mov  rsi, r15                # Arg2 (rsi=tmp2)
  call tolcase
  test eax, eax
  jnz  .cmp_failed_p15

# memcmp
  mov  rdi, r14
  mov  rsi, r15
  mov  rdx, 8[rbp]
  call memcmp@PLT
  test rax, rax
  jnz  .strs_not_eq_p15_2

  xor eax, eax
  jmp .release_mem_p15

.strs_not_eq_p15_1:
  mov eax, -13

.ret_block_p15_1:
  pop r13
  ret

.strs_not_eq_p15_2:
  mov eax, -13
  jmp .ret_block_p15_2

.cmp_failed_p15:
  mov eax, -14

.ret_block_p15_2:
  pop rbx
  pop rbp
  pop r15
  pop r14
  pop r13
  ret


.global findchar
.type findchar, @function

# Function Parameters:
#   rdi=str (const char*)
#   sil=c   (char to find)
#   edx=sensitivity
#   r10=&count (out_ptr, int*)
findchar:
  test rdi, rdi
  jz   .invalid_buff_p16

  push rbx    # count
  xor  ebx, ebx

# Case insensitive (1)
  # Hoist char2lcase(c) outside in r8b
  mov r8b, sil

  cmp sil, 65
  jb  .insensitive_loop_p16
  cmp sil, 90
  ja  .insensitive_loop_p16

  or r8b, 0x20

  # loop over each character; char2lcase inlined
  xor rax, rax    # iterator
.insensitive_loop_p16:
  mov cl, BYTE PTR [rdi + rax]
  cmp cl, 0
  jz  .done_p16

  cmp cl, 65
  jb  .check_p16
  cmp cl, 90
  ja  .check_p16

  or cl, 0x20

.check_p16:
  add eax, 1    # i++
  cmp cl, r8b
  jne .insensitive_loop_p16

  add ebx, 1    # occ++
  jmp .insensitive_loop_p16

# Case sensitive (0)
  xor rax, rax
.sensitive_loop_p16:
  mov cl, BYTE PTR [rdi + rax]
  cmp cl, 0
  jz  .done_p16

  add eax, 1    # i++
  cmp cl, sil
  jne .sensitive_loop_p16

  add ebx, 1    # occ++
  jmp .sensitive_loop_p16

.done_p16:
  test ebx, ebx
  jz   .not_found_p16

  mov DWORD PTR [r10], ebx
  jmp .ret_block_p16

.invalid_buff_p16:
  mov eax, -6
  jmp .ret_block_p16

.not_found_p16:
  mov eax, -17

.ret_block_p16:
  pop rbx
  ret


.global clearStr
.type clearStr, @function

# Function Parameters:
#   rdi=str (dynstr)
  mov eax, -4
  test rdi, rdi
  jz   .ret_block_p17

  mov  rcx, QWORD PTR [rdi]
  test rcx, rcx
  jz   .ret_block_p17

  mov QWORD PTR 8[rdi], 0
  mov QWORD PTR [rdi], 0
  xor eax, eax

.ret_block_p17:
  ret


.global freeStr
.type freeStr, @function

# Function Parameters:
#   rdi=str (dynstr)
  push rbx
  mov  eax, -4

  test rdi, rdi
  jz   .ret_block_p18

  mov  rcx, QWORD PTR [rdi]
  test rcx, rcx
  jz   .ret_block_p18

# free@PLT; preserve rdi
  mov rbx, rdi

  mov  rdi, [rdi]
  call free@PLT

  mov QWORD PTR  8[rbx], 0
  mov QWORD PTR 16[rbx], 0
  xor eax, eax

.ret_block_p18:
  pop rbx
  ret


.global kmp_build_lps
.type kmp_build_lps, @function

# Function Parameters:
#   rdi=pat  (const char*, pattern-string)
#   rsi=plen (pattern-string length, size_t)
#   rdx=&lps (size_t *lps)
kmp_build_lps:
  mov  eax, -6
  test rdi, rdi
  jz   .ret_block_p19

  test rsi, rsi
  jz   .ret_block_p19

  xor eax, eax    # SUCCESS hoisted
  xor rcx, rcx              # len=0
  mov QWORD PTR [rdx], 0    # lps[0]=0

  mov r10, 1    # iterator (i=1, init val)
loop_p19:
  cmp r10, rsi
  jae .ret_block_p19

  mov r8l, BYTE PTR [rdi + r10]    # pat[i]
  mov r9l, BYTE PTR [rdi + rcx]    # pat[len]
  cmp r8l, r9l
  jnz .elseif_p19

  add rcx, 1    # len++
  mov QWORD PTR [rdx + r10], rcx    # lps[i] = len
  add r10, 1    # i++
  jmp .loop_p19

.elseif_p19:
  cmp rcx, 0
  jz  .else_p19

  mov rcx, QWORD PTR [rdx + rcx - 1]    # len = lps[len-1]
  jmp .loop_p19

.else_p19:
  mov QWORD PTR [rdx + r10], 0    # lps[i]=0
  add r10, 1    # i++
  jmp .loop_p19

.ret_block_p19:
  ret


.global kmp_search
.type kmp_search, @function

# Function Parameters;
#   rdi=str (const char*, haystack)
#   rsi=pat (const char*, needle)
#   rdx=kmp_obj (kmp_result*)
kmp_search:
  push r12
  push r13

  test rdi, rdi
  jz   .invalid_buff_p20

  test rsi, rsi
  jz   .invalid_buff_p20

  xor r12, r12    # slen
  xor r13, r13    # plen

# lenstr(str) inlined;
.len_str_p20:
  cmp BYTE PTR [rdi + r12], 0
  jz  .len_pat_p20

  add r12, 1
  jmp .len_str_p20

# lenstr(pat) inlined;
.len_pat_p20:
  cmp BYTE PTR [rsi + r13], 0
  jz  .check_p20

  add r13, 1
  jmp .len_pat_p20

.check_p20:
  test r12, r12
  jz   .invalid_buff_p20

  test r13, r13
  jz   .invalid_buff_p20

  cmp r13, r12
  jae .invalid_buff_p20

# CONTINUE FROM HERE

.invalid_buff_p20:
  mov eax, -6

.ret_block_p20:
  ret

