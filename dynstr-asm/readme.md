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
