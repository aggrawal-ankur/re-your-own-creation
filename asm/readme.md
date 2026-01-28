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

They include: `rbx, r12, r13, r14, r1`

### Caller Saved Registers

The caller function must preserve the original value in these registers as a call to another function can use these registers. The callee is not liable.

They include: `rax, r10, r11`