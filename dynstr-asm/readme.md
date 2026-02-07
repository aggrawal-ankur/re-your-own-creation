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