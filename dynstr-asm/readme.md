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

# Day 4

***February 08, 2026***

Finally, the mysterious segfault resolves. I don't know why I notes r10 as the 4th argument register. It was rcx. That was the issue.

I've to update this in later parts as well.

---

islcase is working fine but tolcase returned -6, which is for invalid buff, what the heck! OK, a register mismatch in `test`. Now it returns -11, which makes far more sense.

---

Everything sorted, except kmp_search. I've tried some things and I'll continue tomorrow.

# Day 5

***February 09, 2026  5:30 PM***

I am done correcting dynstr.asm and it works perfect now. The bus error in kmp_search was really frustrating. I tried many changes but nothing seemed to work. In the end, kmp_build_lps missed the scale factor multiplication in offset calculation, that disturbed everything downstream.

Today I woke up with pain in the lower back, which is kind of disturbing, honestly. But I know that it will vanish because now dynstr.asm is working fine.

I have drawn an ASCII-art after a long time to help me get the layout correctly.
```
rsp -> 2000 (%16 == 0)
*----------*
| ret_addr | -> 1992
*----------*
|   r12    | -> 1984
*----------*
|   r13    | -> 1976
*----------*
|   r14    | -> 1968
*----------*
|   r15    | -> 1960
*----------*
|   rbp    | -> 1952
*----------*
|   rbx    | -> 1944
*----------*
|   rsp-8  | -> 1936 (dummy push)
*----------*
|  VLA(4)  | -> 1904 (A VLA of 4 size_t sized elements for predictable layout)
*----------*
|   rsp-8  | -> 1896 (&kmp_obj, i.e rdx)
*----------*
|   rsp-8  | -> 1888 (VLA Size (32), i.e rcx)
*----------*
```

I've an idea to conclude my findings so far, before I move on to optimizing dynstr.asm, wherever possible.

# Stuff to look for?

***How the prologue is structured?***

At -O0, callee-saved registers and stack reservation is done in the prologue itself and the body is completely separate.

At -O1, the frame pointer (rbp) is mostly omitted under `-fpo`. However, callee-saved register pushing and stack space reservation has a different story.
  - Sometimes, the prologue has meaning, where push/sub are separated from the body. Other times, the prologue is basically meaningless, unless you change your definition of it.
  - Either push/sub can be restricted to the prologue, or they leak into the body. Both designs indicate some things, but the interpretation is not guaranteed to be true 100%.
  - When a procedure has a complex-enough control flow that can lead to different paths but is simple enough to be optimized, the compiler chooses to segregate push/sub based on which path requires how much of them, to optimize memory footprint.
  - When a procedure has a complex control flow, for the sake of **stable anchors and a predictable layout**, the compiler can honor push/sub in the prologue itself.
  - These are the cases when multiple return paths emerge.

***If you see conditional register saves, you know there are distinct execution paths with different resource requirements.***

Example:
  - In dynstr.asm, the procedure cmp2strs has two paths because of case sensitive and insensitive check. In my version, I've implemented two separate paths because the case sensitive one requires no callee-saved register and the sensitive one requires 6 registers and a dummy push of 8-bytes on stack. The only reason I push r13 earlier is to align rsp to a 16-byte boundary in case the case-insensitive path is taken. This design is taken from GCC's output for dynarr.asm at -O1 probably. GCC doesn't implementation this in dynstr.asm however, so yeah.

The prologue speaks a lot about the register pressure.

---

***How many callee-saved registers the compiler is pushing?*** It indicates:
  - how much data needs preservation across sub-calls in the procedure.
  - the register pressure and how complicated data movement is across the procedures.

The higher the number, the more complex data movement is, the more data needs preservation across sub-calls and the more registers are under pressure.

When all the callee-saved registers are pushed on stack, yet you need stack space (for spills), that's a sign of sufficiently great register pressure.

---

***Instruction reordering in complex control flow.***
  - Procedures with complex control flow logic involves stuff which can be silently reordered by the compiler not just for profitability, but logically as well.

---

***A lot of optimization techniques are completely applicable yet the compiler might not emit them for reasons hard to find and verify, if found any.***

Take the output of GCC for dynstr.c at -O1 for example. Most of the procedures have frame pointer while it is neglected at -O1 by the compiler under `-fpo`. I myself have written whole dynstr.asm without any base-pointer.

I am not saying mine is better than GCC's, but the question is **why didn't GCC omitted the frame pointer?** These aren't unanswerable questions obviously, but they demand great understanding of compilers, and I don't have it yet.

A lot of reasons can be economical and based on prioritizing profitability over logical reasoning.

---

***Type-information is largely lost, but not completely.***

The presence of
  - `QWORD PTR` means a 64-bit value,
  - `DWORD PTR` means a 32-bit value,
  - `WORD PTR` means a 16-bit value,
  - `BYTE PTR` means an 8-bit value.

Obviously it is not precise, but it helps in reducing the search space. Like:
  - `QWORD PTR` with arithmetic can mean "pointer arithmetic" or a "size_t" value.
  - `DWORD PTR` is a huge sign for ints.
  - I've not come across any use of `WORD PTR` so far.
  - `BYTE PTR` is best for ASCII-character stuff. But remember, uint_8t is the same thing.

The presence of `movsx` confirms signed-ness. 

The presence of `movzx` can be quite-interesting. It indicates that a value from a small container needs to be zero-extended and moved into a larger container. This doesn't preserve signed-ness, and if the original source, which is getting zero-extended, was a signed container and had a signed value, that can infest as a problem in the later parts of the code.

Conditional jumps are another helping hand to confirm whether we are operating on signed-containers or unsigned-containers. Like we jl and jb for `<`, but jl is for signed values and jb is for unsigned values.

***Signed-ness is not a property of data. It’s a property of interpretation at use sites. Therefore, I believe more mechanisms exist to confirm signed-ness and they'll reveal as I progress.***

---

***To confirm the presence of "arrays", look for offset calculation.***

The general formula is:
```
[base + index*scale] where scale ∈ {1,2,4,8}
```

# Conclusion

I am concluding this journey today. I am not feeling like optimizing this one. It is just about which tradeoffs I am accepting to have. Hopping from one form of expression to the another.

I don't know what's going to be the next thing. I am waiting for the universe's signal to be processed by my subconscious mind. Thank you.
