# Writing the dynamic containers in x64 assembly

That's my next step after reading the LLVM IR at different optimization levels.

LLVM IR did what I expected it to, **to provide data to my brain.exe so that it can think better, hypothesize  better and make better assumptions**.

LLVM IR made implicit things explicit. I was able to improve my reasoning, that's what I wanted.

Now I want to make other hidden things visible. For this, I need to dive deeper into x64 assembly. And before I see what gcc generated for dynarr.c and dynstr.c, I thought it'd be great if I tried to write these containers in x64 assembly myself.

I don't want to compare with gcc or clang. I just want to understand the hidden invariants and constraints better. LLVM IR helped me see them to some extent, now I want to improve on that.

## External Functions

dynarr.c uses these functions and I'll call them as is.
```
malloc@Plt
realloc@Plt
memcpy@Plt
memmove@Plt
free@PLT
```

## Calling Convention

I'm going to follow System V ABI.

### Function Call Argument

| Arg # | Register |
| :---- | :------- |
| Arg 1 | rdi |
| Arg 2 | rsi |
| Arg 3 | rdx |
| Arg 4 | r10 |
| Arg 5 | r8  |
| Arg 6 | r9  |

More than 6? Put remaining on stack.

### Callee Saved Registers

The callee function must reserve the original value in these registers before using them and restore their state before exit.

They include: rbx, rbp, rsp, r12, r13, r14, r15

### Caller Saved Registers

The caller function must preserve the original value in these registers as a call to another function can use these registers. The callee is not liable.

They include: rax, rcx, r10, r11

# Day 1 Takeaways

Today (January 28, 2026) is the first day and I've implemented `init()` in x64 assembly.

As I learned x64 assembly back in May 2025, that's when I wrote it. It has been 8 months have passed since then, so it has become a little rusty. But I am glad I am able to sharp myself this fast.

A lot is different, honestly. Thinking in assembly is quite a lot different than C. That's a thing I realized in May 2025 only, but honestly, practising it is a different thing, which I am doing now.

Every language is designed with different things in mind, which is why there are different advantages and tradeoffs. For example, arithmetic overflow wraps in C, but you can capture it in assembly.

Assembly forces you to think differently. Every decision you make is explicit because you can't chain thoughts like C. You've to branch to enforce non-linear flow, which can get complicated due to the amount of conditional jumps available in x64-asm.

One thing I realized this time is that writing assembly involves thinking on two lines. First you think about what is linear, stuff which executes one-by-one plainly without any decision-making. But linearity is not enough. The flow deviates or branches on conditions, and branches can get really messy here. So you have to think in terms of when is branching not required (which becomes our linear code) and the exact opposite of it, where branches become real.

As usual, I am leaving lots of comments, I am annotating blocks of assembly with how they align with the C source and assembly-centric notes. For example - "always pop registers in opposite order of push". I am leaving these notes so that I can get used to the assembly's way of thinking.

Register hygiene is something I'll learn slowly. Variables are pretty much non-existing in assembly. You have registers or memory locations on stack. That really forces you to think different than C because the notion of scratch space is different here. Then comes clobbering of register, which you have to ensure to avoid using garbage values. You've to use registers wisely as they can represent lifetime. Compilers use them carefully, which is why they represent state. If I used them recklessly, it'll get tough and complicated later while exploring the disassembly.

Understanding of RFLAGS is a must. How CF, ZF, SF etc work and what manipulates them is important.