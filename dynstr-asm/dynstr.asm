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

  mov eax, -1    # No separate branch because it's destined to execute if init is ran on an initialized dynstr by mistake
  cmp QWORD PTR [rdi], 0
  jnz .ret_block_p1

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
  jmp .success_p2

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
  xor rax, rax
.len:
  cmp BYTE PTR [rdi + rax], 0
  jz  .ret_block_p3

  add rax, 1
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
  xor rbx, rbx
.len_p4:
  cmp BYTE PTR [rsi + rbx], 0
  jz  .done_p4
  add rbx, 1
  jmp .len_p4

.done_p4:
  test rbx, rbx
  jz   .invalid_buff_p4

# extend
  # Arg1 (rdi=dest) already set
  mov  rsi, rbx    # Arg2 (rsi=srclen+1)
  add  rsi, 1
  call extendCap
  test eax, eax
  jnz  .ret_block_p4

# memcpy;
  # Arg1 (rdi=dest)
  mov rdi, [r14]                 # base
  add rdi, QWORD PTR 8[r14]      # + offset

  mov  rsi, r15    # Arg2 (rsi=src)
  mov  rdx, rbx    # Arg3 (rdx=bytes)
  call memcpy@PLT

  add QWORD PTR 8[r14], rbx       # dest->len += srclen
  mov rcx, QWORD PTR [r14]        # base
  mov QWORD PTR [rcx + rbx], 0    # NULL-terminator

  xor eax, eax
  jmp .ret_block_p4

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
  # No need to realign rsp as nothing is called.
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
  lea rcx, [rcx + rsi]        # *out = &str->data[idx]
  mov QWORD PTR [rdx], rcx    # *out

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
#   rcx=&outstr (callee allocated buffer)
getslicedstr:
  push r13
  push r14
  push r15

  mov  eax, -4
  test rdi, rdi
  jz   .ret_block_p7

  mov  r8, QWORD PTR [rdi]
  test r8, r8
  jz   .ret_block_p7

# range validation
  mov r8, QWORD PTR 8[rdi]
  cmp rsi, r8
  jae .invalid_range_p7
  cmp rdx, r8
  jae .invalid_range_p7
  cmp rsi, rdx
  jae .invalid_range_p7

# memcpy; preserve rdi and rcx and compute slen in a callee-saved register
  mov r13, rdi    # &str
  mov r14, rcx    # &outstr
  mov r8, rsi    # preserve start

  # Arg3 (rdx=slen)
  sub rdx, rsi    # end-start
  mov r15, rdx    # preserve slen

  # Arg1 (rdi=outstr)
  mov rdi, r14

  # Arg2 (rsi=&str->data[start])
  mov rsi, QWORD PTR [r13]    # str->data (base)
  lea rsi, [rsi + r8]        # &str->data[start]

  call memcpy@PLT
  mov  BYTE PTR [r14 + r15], 0

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
  xor rbx, rbx
.len_p8:
  cmp BYTE PTR [rdi + rbx], 0
  jz  .done_p8
  add rbx, 1
  jmp .len_p8

.done_p8:
  test rbx, rbx
  jz   .invalid_buff_p8

# memcpy; preserve rdi
  mov r14, rdi

  mov  rdi, rsi
  mov  rsi, r14
  mov  rdx, rbx
  call memcpy@PLT

  xor eax, eax
  jmp .ret_block_p8

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

  mov eax, -9     # failure hoisted
  xor rcx, rcx    # iterator

.check_loop_p11:
  mov dl, BYTE PTR [rdi + rcx]
  cmp dl, 0
  jz  .done_p11

  cmp dl, 90
  ja  .inc_p11
  cmp dl, 65
  jae .ret_block_p11

.inc_p11:
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

  mov eax, -9     # failure hoisted
  xor rcx, rcx    # iterator

.check_loop_p12:
  mov dl, BYTE PTR [rdi + rcx]
  cmp dl, 0
  jz  .done_p12

  cmp dl, 97
  jb  .inc_p12
  cmp dl, 122
  jbe .ret_block_p12

.inc_p12:
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

  # Arg3 (rdx=bytes) needs to be calculated
  xor r13, r13
.len_p13:
  cmp BYTE PTR [rdi + r13], 0
  jz  .done_p13

  add r13, 1
  jmp .len_p13

.done_p13:
  test r13, r13
  jz   .invalid_buff_p13

  mov rsi, rdi  # Arg2 (rsi=str)
  mov rdi, rbx  # Arg1 (rdi=lcase)
  mov rdx, r13  # Arg3 (rdx=r13=bytes)
  call memcpy@PLT
  mov BYTE PTR [rbx + r13], 0

# Loop over each character and run char2lcase on it.
  xor rcx, rcx    # iterator
.convert2lcase_p13:
  mov dl, BYTE PTR [rbx + rcx]
  cmp dl, 0
  jz  .check_lcase_p13

  # char2lcase inlined;
  cmp dl, 65
  jb .end_p13    # Not uppercase, do nothing.
  cmp dl, 90
  ja .end_p13    # Not uppercase, do nothing.

  or dl, 0x20    # Uppercase confirmed, convert.
  mov BYTE PTR [rbx + rcx], dl    # lcase[i] = char2lcase(lcase[i])

.end_p13:
  add rcx, 1
  jmp .convert2lcase_p13

# islcase inlined
  xor rcx, rcx    # iterator
.check_lcase_p13:
  mov dl, BYTE PTR [rbx + rcx]
  cmp dl, 0
  jz  .success_p13

  cmp dl, 90
  ja  .inc_p13
  cmp dl, 65
  jae .lcase_failed_p13

.inc_p13:
  add rcx, 1
  jmp .check_lcase_p13

.invalid_buff_p13:
  mov eax, -6
  jmp .ret_block_p13

.lcase_failed_p13:
  mov eax, -11
  jmp .ret_block_p13

.success_p13:
  xor eax, eax

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

  # Arg3 (rdx=bytes) needs calculation
  xor r13, r13
.len_p14:
  cmp BYTE PTR [rdi + r13], 0
  jz  .done_p14

  add r13, 1
  jmp .len_p14

.done_p14:
  test r13, r13
  jz   .invalid_buff_p14

  mov rsi, rdi  # Arg2 (rsi=str)
  mov rdi, rbx  # Arg1 (rdi=ucase)
  mov rdx, r13  # Arg3 (rdx=bytes)
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
  xor rcx, rcx    # iterator
.check_ucase_p14:
  mov dl, BYTE PTR [rbx + rcx]
  cmp dl, 0
  jz  .success_p14

  cmp dl, 97
  jb  .inc_p14
  cmp dl, 122
  jbe .ucase_failed_p14

.inc_p14:
  add rcx, 1
  jmp .check_ucase_p14

.invalid_buff_p14:
  mov eax, -6
  jmp .ret_block_p14

.ucase_failed_p14:
  mov eax, -12
  jmp .ret_block_p14

.success_p14:
  xor eax, eax

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
#   edx=sensitivity (int)
cmp2strs:
  push r13

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

  mov rcx, QWORD PTR 8[rdi]
  mov r10, QWORD PTR 8[rsi]
  cmp rcx, r10
  jnz .strs_not_eq_p15_1

  test edx, edx
  jnz  .case_insensitive_check

# Case sensitive (0)
  mov  rdx, QWORD PTR 8[rdi]    # Arg3 (rdx=str1->len)
  mov  rsi, QWORD PTR  [rsi]    # Arg2 (rsi=str2->data)
  mov  rdi, QWORD PTR  [rdi]    # Arg1 (rdi=str1->data)
  call memcmp@PLT
  test rax, rax
  jnz  .strs_not_eq_p15_1

  xor eax, eax
  jmp .ret_block_p15_1

.case_insensitive_check:
# Case insensitive (1)
  # Since pushing registers is only required in case of insensitive check.
  # But for alignment purpose, we need to push one register at least, so only two registers are being pushed here.
  push r12    # preserve the space subtracted for VLA
  push r14    # tmp1[str1->len+1]
  push r15    # tmp2[str2->len+1]
  push rbp    # str1
  push rbx    # str2
  sub  rsp, 8
  mov  rbp, rdi
  mov  rbx, rsi

  # VLA aligned-space calculation
  add rcx, r10    # total bytes required: (rcx, r10)

  add rcx, 2      # count for '\0'
  add rcx, 15     # (total + 15)
  and rcx, -16    # (total + 15) & ~15
  mov r12, rcx    # preserve VLA space count
  sub rsp, rcx

  mov r14, rsp                # &tmp1[str1->len+1]
  lea r15, [rsp + r10 + 1]    # &tmp2[str2->len+1]
  # For these reasons, some arrays allow appending out of bounds because they end up using the "alignment space"

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
  mov  rdx, QWORD PTR 8[rbp]
  call memcmp@PLT
  test rax, rax
  jnz  .strs_not_eq_p15_2

  xor eax, eax
  jmp .ret_block_p15_2

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
  add rsp, r12
  add rsp, 8
  pop rbx
  pop rbp
  pop r15
  pop r14
  pop r12
  pop r13
  ret


.global findchar
.type findchar, @function

# Function Parameters:
#   rdi=str (const char*)
#   sil=c   (char to find)
#   edx=sensitivity
#   rcx=&count (out_ptr, int*)
findchar:
  push rbx
  xor ebx, ebx    # count

  test rdi, rdi
  jz   .invalid_buff_p16

  test edx, edx
  jz   .sensitive_loop_p16

# Case insensitive (1)
  # Hoist char2lcase(c) outside in r8b
  mov r8b, sil

  cmp sil, 65
  jb  .insensitive_loop_p16
  cmp sil, 90
  ja  .insensitive_loop_p16

  or r8b, 0x20

  # loop over each character; char2lcase inlined
  xor r10, r10    # iterator
.insensitive_loop_p16:
  mov dl, BYTE PTR [rdi + r10]
  cmp dl, 0
  jz  .done_p16

  cmp dl, 65
  jb  .check_p16
  cmp dl, 90
  ja  .check_p16

  or dl, 0x20

.check_p16:
  add r10, 1    # i++
  cmp dl, r8b
  jne .insensitive_loop_p16

  add ebx, 1    # occ++
  jmp .insensitive_loop_p16

# Case sensitive (0)
  xor r10, r10
.sensitive_loop_p16:
  mov dl, BYTE PTR [rdi + r10]
  cmp dl, 0
  jz  .done_p16

  add r10, 1    # i++
  cmp dl, sil
  jne .sensitive_loop_p16

  add ebx, 1    # occ++
  jmp .sensitive_loop_p16

.done_p16:
  test ebx, ebx
  jz   .not_found_p16

  mov DWORD PTR [rcx], ebx
  xor eax, eax
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
.loop_p19:
  cmp r10, rsi
  jae .ret_block_p19

  mov r8b, BYTE PTR [rdi + r10]    # pat[i]
  mov r9b, BYTE PTR [rdi + rcx]    # pat[len]
  cmp r8b, r9b
  jnz .elseif_p19

  add rcx, 1    # len++
  mov QWORD PTR [rdx + r10*8], rcx    # lps[i] = len
  add r10, 1    # i++
  jmp .loop_p19

.elseif_p19:
  cmp rcx, 0
  jz  .else_p19

  mov rcx, QWORD PTR [rdx + rcx*8 - 8]    # len = lps[len-1]
  jmp .loop_p19

.else_p19:
  mov QWORD PTR [rdx + r10*8], 0    # lps[i]=0
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
  push r12    # slen
  push r13    # plen
  push r14    # VLA *lps
  push r15    # str (rdi)
  push rbp    # pat (rsi)
  push rbx    # rsp
  sub rsp, 8  # Dummy

  test rdi, rdi
  jz   .invalid_buff_p20

  test rsi, rsi
  jz   .invalid_buff_p20

  test rdx, rdx
  jz   .invalid_kmp_obj

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

# VLA allocation (size_t lps[plen])
  mov rcx, r13    # plen
  shl rcx, 3      # plen * sizeof(size_t) as lps is a size_t array
  add rcx, 15     # total + 15
  and rcx, -16    # (total + 15) & ~15
  sub rsp, rcx
  mov r14, rsp    # size_t lps[plen]

# Stack spill
  sub rsp, 8    # kmp_obj (rdx) || 8[rsp]
  mov QWORD PTR [rsp], rdx    # &kmp_obj

  sub rsp, 8    # VLA size      ||  [rsp]
  mov QWORD PTR [rsp], rcx    # VLA size preserved on stack

  mov rbx, rsp    # preserve rsp (top) in rbx for accessing stack

# kmp_build_lps; preserve rdi, rsi and rdx
  mov r15, rdi
  mov rbp, rsi

  mov  rdi, rbp    # Arg1 (rdi=pat)
  mov  rsi, r13    # Arg2 (rsi=plen)
  mov  rdx, r14    # Arg3 (rdx=lps)
  call kmp_build_lps
  test eax, eax
  jnz  .ret_block_p20_2

# while loop
  xor rdi, rdi    # i=0
  xor rsi, rsi    # k=0
  xor rdx, rdx    # count=0

  # Hoist the base (kmp_obj->indices) outside
  mov r9, QWORD PTR 8[rbx]    # &kmp_obj
  mov r9, QWORD PTR 8[r9]     # kmp_obj->indices

.while_p20:
  cmp rdi, r12    # i < slen
  jae .check_count_p20

  mov r8b,  BYTE PTR [r15 + rdi]    # str[i]
  mov r11b, BYTE PTR [rbp + rsi]    # pat[k]
  cmp r8b, r11b

  jne .elseif_p20

  add rdi, 1    # i++
  add rsi, 1    # k++

  cmp rsi, r13    # (k == plen)
  jne .while_p20

  mov rax, rdi    # i
  sub rax, rsi    # (i-k)
  mov QWORD PTR [r9 + rdx*8], rax    # kmp_obj->indices[count]=(i-k)

  add rdx, 1    # count++
  lea rax, [r13-1]

  mov rsi, QWORD PTR [r14 + rax*8]    # k = lps[plen-1]
  jmp .while_p20

.elseif_p20:
  test rsi, rsi
  jz   .else_p20

  lea rax, [rsi-1]    # k-1
  mov rsi, QWORD PTR [r14 + rax*8]    # k = lps[k-1]
  jmp .while_p20

.else_p20:
  add rdi, 1    # i++
  jmp .while_p20

.check_count_p20:
  test rdx, rdx
  jnz  .set_count_p20

  mov r9, QWORD PTR 8[rbx]
  mov QWORD PTR  [r9], 0
  mov QWORD PTR 8[r9], 0

  mov eax, -16    # SUBSTR_NOT_FOUND
  jmp .ret_block_p20_2

.set_count_p20:
  mov r9, QWORD PTR 8[rbx]
  mov QWORD PTR [r9], rdx    # kmp_obj->count = count (rdx)

  xor eax, eax    # SUCCESS
  jmp .ret_block_p20_2

.invalid_buff_p20:
  mov eax, -6
  jmp .ret_block_p20_1

.invalid_kmp_obj:
  mov eax, -18
  jmp .ret_block_p20_1

.ret_block_p20_1:
  add rsp, 8
  pop rbx
  pop rbp
  pop r15
  pop r14
  pop r13
  pop r12
  ret

.ret_block_p20_2:
  mov rsp, rbx
  mov r10, QWORD PTR [rsp]
  add rsp, 8
  add rsp, 8
  add rsp, r10
  add rsp, 8
  pop rbx
  pop rbp
  pop r15
  pop r14
  pop r13
  pop r12
  ret


.global isin
.type isin, @function

# Function Parameters:
#   rdi=kmp_res (kmp_result*)
isin:
  mov  eax, -15
  test rdi, rdi
  jz   .ret_block_p21

  cmp QWORD PTR [rdi], 0
  jz  .substr_not_found_p21

  xor eax, eax
  jmp .ret_block_p21

.substr_not_found_p21:
  mov eax, -16

.ret_block_p21:
  ret


.global firstOccurrence
.type firstOccurrence, @function

# Function Parameters:
#   rdi=kmp_res (kmp_result*)
#   rsi=idx (int*, out_ptr)
firstOccurrence:
  mov  eax, -15
  test rdi, rdi
  jz   .ret_block_p22

  cmp QWORD PTR [rdi], 0
  jz  .substr_not_found_p22
  cmp QWORD PTR 8[rdi], 0
  jz  .substr_not_found_p22

  mov rcx, QWORD PTR 8[rdi]    # base
  mov rcx, QWORD PTR  [rcx]    # indices[0]
  mov QWORD PTR [rsi], rcx     # *idx = kmp_res->indices[0]

  xor eax, eax
  jmp .ret_block_p22

.substr_not_found_p22:
  mov QWORD PTR [rsi], -1
  mov eax, -16

.ret_block_p22:
  ret


.global allOccurrences
.type allOccurrences, @function

# Function Parameters:
#   rdi=kmp_res (kmp_result*)
#   rsi=indices (size_t**, outptr)
#   rdx=count (int*)
allOccurrences:
  mov  eax, -15
  test rdi, rdi
  jz   .ret_block_p23

  cmp QWORD PTR [rdi], 0
  jz  .substr_not_found_p23
  cmp QWORD PTR 8[rdi], 0
  jz  .substr_not_found_p23

  mov rcx, QWORD PTR 8[rdi]
  mov QWORD PTR [rsi], rcx

  mov rcx, QWORD PTR [rdi]
  mov QWORD PTR [rdx], rcx

  xor eax, eax
  jmp .ret_block_p23

.substr_not_found_p23:
  mov QWORD PTR [rsi], 0
  mov QWORD PTR [rdx], -1
  mov eax, -16

.ret_block_p23:
  ret

