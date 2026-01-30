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

They include: rbx rbp r12 r13 r14 r15

### Caller Saved Registers

The caller function must preserve the original value in these registers as a call to another function can use these registers.

As the callee is not liable to manage their state, they are excellent scratchpads.

They include: rax rcx rdx rsi rdi r8 r9 r10 r11

# Register Hygiene

Use caller-saved registers for:
  - temporaries
  - intermediate math
  - values that die before calls

Use callee-saved registers for:
  - long-lived values across calls
  - struct base pointers
  - loop invariants that survive calls

**rsp is not a scratch register**

**rbp is scratch only when I give up the base pointer.**

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

# Day 2 Takeaways

Date: January 29, 2026

Even though I am moving slowly without hurries, the progress sometimes feel less. That's because I am managing physical pain for so many days at this point. This chronic pain doesn't even go after stretching. And when I don't get proper rest, that's enough for me. But no matter what, I always learn starting from evening. 3-4 hours is the maximum I am reaching these days, throughout the day. I learn ~1h in morning.

It is complicated, but leave it.

Today I implemented extend(). I was done with the implementation in morning only, ~1h. Then I didn't do anything until evening, because I went to bed late and I didn't got adequate sleep, so I woke up with pain. And my afternoon sleep was non-existing too.

In the evening, I started thinking about the assembly I've written and refactored it.

I am improving my register hygiene and I've also created a heading for it. This has helped me remove the unnecessary register pushing to align the stack or reducing rsp for the same cause, which is great, because it removes unnecessary lines.

I am also starting to think in terms of register live ranges.

For the first time, I implemented one thing I've learned from LLVM IR, and I also understood it to the point I was able to relate the behavior with something else. Remember the IR performing addition before comparison checks? Like in lenstr where `str[0] == '\0'` was already checked before so it adds 1 and then checks the condition on the moved pointer. **That's exactly what a do-while does.** It is amusing to me as well. Earlier I've written the `while (cap < total) cap *= 2` loop in the same way, but then I changed it.

I've used `imul` this time because it discards overflows beyond 64-bit, something `mul` doesn't do. Also, mul operates on the accumulator by default, so there is no way to pass to registers of our convenience. `mul` and `imul` are practically the same here because we only need the lower 64-bits in the output, and if an overflow was there, it is already in UB.

I am also understanding that I should try as much as possible to use caller-saved registers for scratchpads as they don't need to be pushed on the stack. It is clean and better.

***Structure is emergent, not preserved. Therefore, I must think in terms of register live ranges, they tell which registers are active in a region of assembly. That's the shift in thinking I need.***

The loop thing: `while (cap < total) cap *= 2` also taught me one important lesson. ***A lot of times, the compiler is not spitting assembly out of witchery. The compiler thinks a lot, it reasons from multiple angles.***

***To understand assembly better, I need to improve my reasoning. I need to think more. I need to observe more. This loop thing, I've seen this 10s of times if not 100s while reading the LLVM IR, but I never reasoned what else this pattern could match, which I did today and found that it matches the semantics of a do-while loop. I can't write and reason simultaneously. I must give proper time, energy and attention to this.***

***The compiler's line of reasoning is not magical or unorthodox, it's mathematical and logical. The compiler notices more than me. That's why asking questions about the generated assembly is simply non-negotiable because everything there is properly reasoned. If I don't understand a part, there is always a reasoning behind why the compiler chose it, which can only be found by asking questions and looking with what we can call "unconventional angles".***

***The line of reasoning "required" vs the line of reasoning "I currently function with" is the gap I need to fill.***

About register hygiene, I've learned that *registers don't keep meaning attached to them*. It's transient. The meaning depends on the region it is active in and the way it is being used (the value in computation).

***When memory and registers both are involved, memory is the more authoritative source than a register to reason about a value.*** When I understood this line, I removed copying rbx into rcx which is what `size_t cap = arr->capacity` is about. I let rbx (arr->capacity) undergo `cap *= 2` because the original value of arr->capacity is still accessible at `rdi + 8*3`. But I did preserved rdi before realloc.

A thing about register live ranges is that *a variable in C is alive in its block, if it is a fn, it is alive in the whole fn. But a register is only alive in the region it is used.*

---

I wanted to see if I can improve init() based on these new findings, but I am already late and I don't want to sleep late today. So I'll do that tomorrow.

# Day 3 Takeaways

**January 30, 2026**

**10:25 PM**

Today was fantastic and a very memorable day in my life. I loved living today, a lot.

I woke up very relaxed, with fading pain in my body. I stretched as usual and I felt great.

I started with improving init(). Then I wrote pushOne. Then I changed rax to eax because DynArrStatus is an enum and enums are of type int, which involves signed values. Then I wrote pushMany. My lord, write pushMany was a smooth journey. I've simply forgotten what are hiccups. It went so smooth. In the evening, after 9.30 PM, I completed boundcheck and getelementptr as well. And I still don't want to quit, but I need to stop now and wind up the day, so that I can sleep on time and wake up relaxed tomorrow as well.

Today, I reasoned better, I thought a little more, and I made these things a little more autonomous then forced.

I've focused on thinking in terms of "register live ranges", which definitely helped me fight less and write better assembly. Also, it is one of the keys to understand and improve my register hygiene.

I am definitely improving my register hygiene and how to prioritize callee vs caller saved registers as scratchpads. It's not complicated, but not simple either. It takes time and attention, and I am in no hurry.

One important thing thing I learned today is also related to callee vs caller saved registers. I've always saved callee-saved registers, but this time, pushOne called extend, so pushOne effectively became the caller and extend became the callee. I thought that since rdi already contains the ptr to the dynarr struct, I need not to change or preserve it. But I was wrong. Now pushOne is the caller, and if the caller wants to reuse the caller-saved registers, it must preserve them, either in callee-saved registers or spill to stack. That thing was an important lesson in register hygiene. Now I feel less confused about which registers to use.

A lot of times, I forget xoring rax in the end for success, in excitement. Also, once I preserve the original arguments, I sometimes forget to use the updated registers, which I am learning to prevent.

Sometimes, type information can leak through register widths. Like the functions with DynArrStatus as the return type are basically ints, and the assembly encodes this with `eax` instead of `rax`. That's a signal. If the return is rax, we can assume 64-bit value. If movsxd is used on a register, that's a signal that the value belongs to a signed container.

Based on the previous paragraph, I had a question. ***If a procedure returned in eax and the caller tested rax, what will happen? Any write to a 32-bit register is zero-extended into the full 64-bit one.***
  - If -1 is returned in eax, it is 0xffffffff. Apply sign-extension, it becomes 0xffffffffffffffff. But it is still interpreted as -1 due to movsxd.
  - In case of zero-extension, the remaining 32-bits will be zeroed and it will look like this: 0x00000000ffffffff, i.e 4.29b+

***That's why, if the callee returns in rax, the caller must test eax only.***

Last, `NULL` or `(void*)0` is `0` in x64-asm.
