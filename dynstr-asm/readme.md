# It's time to write dynstr.asm

***February 05, 2026  09:56 PM***

I am done with dynarr.asm and it's time to write **dynstr.asm**.

Done with first 4 functions, not checked yet. This time, I am going to check once every procedure is written.

As always, the source is undergoing some changes, and checking if they work or break is also going to be done in the end.

Signing off.

# Day 2

***February 06, 2026  10:20 AM***

Good morning. I woke up fresh and relaxed, and I am done with my first session of (~56 minutes) where I've implemented the next 4 procedures (boundcheck, getstr, getslicedstr and copystr).

I am already inlining lenstr and boundcheck whenever I get the opportunity, and I am going to do so with copystr as well. I see a lot of functions here can be inlined and I am not going to lose that opportunity to improve my understanding of function inlining and how to glue functions efficiently.

---

Session 2, ~1hr, 4 procedures done (char2lcase, char2ucase, islcase, isucase).

---

Session 3, ~190m (>3h), 2 procedures done (tolcase and toucase). They were inline heavy. I've written the assembly, but I know there will subtle mistakes.

---

Session 4, ~2hr, next 2 procedures done (cmp2strs and findchar).

In cmp2strs, I was stuck at returns (releasing memory, register popping) because the procedure was using so many registers on the second path and only 1 register on the first path. This time, I separated register pushes because the number was huge, which made returns complicated. In the end, I separated the return paths as well.

findchar was simple.

Today I've written 635 lines of assembly. I know the metric is not the best, but 635 lines of handwritten x64-assembly is something I could've never thought I'd write any day by any chance. Thanks to my past self for doing all that unglamorous work, I am grateful for it.

Done for the day.

# Day 3

***February 07, 2026***

Session 1, 54 mins, kmp_build_lps done and kmp_search in progress.

---

***01:14 PM***

Session 2, ~1h 30m, dynstr.asm done.

Line stats: 1157 lines in total.

As usual, the original source has underwent some minor changes, so I'll test the source first and make changes in the assembly if further changes are made. Then I'll test my handwritten assembly.

---

45 mins and I am done writing tests.c and dynstr.c is working fine.

The first change was in the logic of extendCap:
```c
if (str->cap > add) return SUCCESS;
// to
if (str->cap > (str->len + 1 + add)) return SUCCESS;
```
Early logic was wrong, so I've replaced it.

The second one was in getstr's boundcheck:
```c
if (boundcheck(0, str->len, idx)) return -INVALID_IDX;
// to
if (boundcheck(0, str->len, idx) != 1) return -INVALID_IDX;
```

Everything else is fine. Next comes testing **dynstr.asm**.

## Testing dynstr.asm

6:13 pm

### First Attempt

As usual, errors.
```bash
dynstr.asm: Assembler messages:
dynstr.asm:116: Error: `BYTE PTR [rdi+eax]' is not a valid base/index expression
dynstr.asm:155: Error: `BYTE PTR [rsi+ebx]' is not a valid base/index expression
dynstr.asm:160: Error: operand size mismatch for `movzx'
dynstr.asm:161: Error: no such instruction: `nlen'
dynstr.asm:171: Error: operand size mismatch for `movzx'
dynstr.asm:280: Error: invalid use of register
dynstr.asm:322: Error: `BYTE PTR [rdi+ebx]' is not a valid base/index expression
dynstr.asm:332: Error: operand size mismatch for `movzx'
dynstr.asm:908: Error: operand type mismatch for `mov'
dynstr.asm:909: Error: operand type mismatch for `mov'
dynstr.asm:910: Error: operand size mismatch for `cmp'
dynstr.asm:1024: Error: invalid use of register
/usr/bin/ld: cannot find dynstr.o: No such file or directory
collect2: error: ld returned 1 exit status
./build.sh: 4: ./main: not found
rm: cannot remove 'main': No such file or directory
```

The `BYTE PTR` issue is because of rdi + eax, which should be rdi + rax. Later part of the code already uses that.

The `movzx` error should resolve because eax/ebx is changed to rax/rbx

Line 161 - wrong comment style.

Line 280 was probably missing a `QWORD PTR`:
```asm
mov r15, [rdx - rsi]
# to
mov r15, QWORD PTR [rdx - rsi]
```
Line 1024 has the same issue.

Line 908, 909 and 910:
```asm
mov r8l, BYTE PTR [rdi + r10]    # pat[i]
mov r9l, BYTE PTR [rdi + rcx]    # pat[len]
cmp r8l, r9l
```
I thought that the lower 8-bits are addressed with an l-suffix. I was wrong.
```asm
mov r8b, BYTE PTR [rdi + r10]    # pat[i]
mov r9b, BYTE PTR [rdi + rcx]    # pat[len]
cmp r8b, r9b
```

### Second Attempt

2 errors remain:
```bash
dynstr.asm: Assembler messages:
dynstr.asm:280: Error: invalid use of register
dynstr.asm:1024: Error: invalid use of register
/usr/bin/ld: cannot find dynstr.o: No such file or directory
collect2: error: ld returned 1 exit status
./build.sh: 4: ./main: not found
rm: cannot remove 'main': No such file or directory
```

I think I have to manually subtract and then mov.

### Third Attempt

New class of errors:
```bash
/usr/bin/ld: dynstr.o: in function `.len_p4':
dynstr.asm:(.text+0x101): undefined reference to `extend'
/usr/bin/ld: dynstr.o: in function `.inc_cap':
dynstr.asm:(.text+0x9b): undefined reference to `.success'
/usr/bin/ld: dynstr.o: in function `len_p8':
dynstr.asm:(.text+0x1ea): undefined reference to `.len_p8'
/usr/bin/ld: dynstr.o: in function `cmp2strs':
dynstr.asm:(.text+0x462): undefined reference to `.release_mem_p15'
/usr/bin/ld: dynstr.o: in function `loop_p19':
dynstr.asm:(.text+0x589): undefined reference to `.loop_p19'
/usr/bin/ld: dynstr.o: in function `.elseif_p19':
dynstr.asm:(.text+0x599): undefined reference to `.loop_p19'
/usr/bin/ld: dynstr.o: in function `.else_p19':
dynstr.asm:(.text+0x5aa): undefined reference to `.loop_p19'
/usr/bin/ld: dynstr.o: in function `while_p20':
dynstr.asm:(.text+0x65d): undefined reference to `.while_p20'
/usr/bin/ld: dynstr.asm:(.text+0x679): undefined reference to `.while_p20'
/usr/bin/ld: dynstr.o: in function `.elseif_p20':
dynstr.asm:(.text+0x688): undefined reference to `.while_p20'
/usr/bin/ld: dynstr.o: in function `.else_p20':
dynstr.asm:(.text+0x691): undefined reference to `.while_p20'
collect2: error: ld returned 1 exit status
./build.sh: 4: ./main: not found
rm: cannot remove 'main': No such file or directory
```

extend -> extendCap
.success -> .success_p2
len_p8 -> .len_p8
.release_mem_p15 -> .ret_block_p15_2
loop_p19 -> .loop_p19
while_p20 -> .while_p20

### Fourth Attempt

It runs this time, but with problems.
```bash
Running init()....
  res: -1
  len: 0
  cap: 0


Running populate(also checks lenstr and extendCap)....
  res: -4
  len: 0
  cap: 0
  ptr:(null)

Running getstr(also checks boundcheck internally)....
  res: -7
string thru a pointer returned by getstr: (null)

Running getslicedstr()....
  res: -4
string thru a pointer returned by getslicedstr: 

Running islcase()....
  res: -6


Running tolcase(also copystr internally)....
  res: -6
  res: -9
Org: (null)lcase: �[
��

Running isucase()....
  res: -6


Running toucase(also copystr internally)....
  res: 0
  res: -9
Org: (null)ucase: 

Running cmp2strs() in sensitive mode....
  res: 0
Running cmp2strs() in insensitive mode....
  res: 0


Running findchar()....
Segmentation fault
```
Everything failed, basically!

Why init() failed is driving me crazy. Why? Very subtle mistake. I was doing:
```asm
test rdi, rdi
jnz  .ret_block_p1
```
when the requirement was:
```asm
cmp QWORD PTR [rdi], 0
```

### Fifth Attempt

At least init() ran.
```bash
Running init()....
  res: 0
  len: 0
  cap: 10


Running populate(also checks lenstr and extendCap)....
  res: -6
  len: 0
  cap: 10
  ptr:

Running getstr(also checks boundcheck internally)....
  res: -7
string thru a pointer returned by getstr: (null)

Running getslicedstr()....
  res: -4
string thru a pointer returned by getslicedstr: 

Running islcase()....
  res: -9


Running tolcase(also copystr internally)....
  res: -6
  res: -9
Org: lcase: �7VT�

Running isucase()....
  res: -9


Running toucase(also copystr internally)....
  res: -6
  res: -9
Org: ucase: 

Running cmp2strs() in sensitive mode....
  res: 0
Running cmp2strs() in insensitive mode....
  res: 0


Running findchar()....
Segmentation fault
```

From now, the commit history will speak as the changes are many and I can't account for all.

---

***10:09 PM***

I am done for the day. I am stuck at getslicedstr. I simply can't comprehend what's wrong here. I need rest now.