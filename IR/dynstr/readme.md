# Reading the LLVM IR for dynstr.c

Although I've generated the IRs and started exploring them, but I thought, maybe dynstr.c also require some modification! Yes, it definitely does.

But before I could make those changes, I already had the stats noted down. After making the modifications, I checked the line stats again, and this is how the difference looks like:

```bash
clang -S -emit-llvm -O0 dynstr/dynstr.c -o IR/dynstr/O0.ll 
```

Line Stats:

| Source | C   | -O0  | -O1  | -O2  | -O3  |
| :----- | :-- | :--- | :--- | :--- | :--- |
| Old    | 328 | 1926 | 1735 | 1742 | 1742 |
| New    | 311 | 1767 | 1198 | 1186 | 1186 |

Notice how the difference between O1 and O2 is so much after making those modification. I started by improving the error handling, then I moved to logic bugs. I have removed concat2d() because it was identical with populate(). I have churned a lot of lines in the KMP section because the consumer functions had redundant code. Last, I made some minor adjustments in how I had ptr declarations. That's it.

But the jump is still interesting. -O0 still had 1767 lines and at O2 it becomes 1198. The jump is about 569 lines. That's definitely something. Let's find it out.

## -O0

*As I have already explored dynarr.c in detail, I'll avoid similar stuff.*

---

As usual, everything is very long and detailed. It is not **unnecessarily long**, obviously. One interesting thing I found in boundcheck was a phi-node. Then I quickly opened the -O0 IR for dynarr.c and found that it is present there as well. So, nothing interesting.

The first interesting thing I found is in `char2lcase`.
```
define dso_local signext i8 @char2lcase(i8 noundef signext %0) #0
```
`signext` is the newcomer. *signext indicates that the parameter or the return value must be sign-extended to the extent required by the target's ABI (which is usually 32-bits) by the caller (for a parameter) or the callee (for a return value).*

That's the reason why we see `c` getting sign extended every time it is used.

Same story is repeated for `char2ucase`.

When I was looking at `islcase`, everything seemed similar, except one thing. islcase also operate on single characters, and you must sign-extend them to i32 for abi-compliance. But since we are not returning the character itself, the attribute `signext` is absent.

---

I have skipped kmp_build_lps and kmp_search for now. And I am gonna do that for the remaining IRs as well. I'll explore them in last.

## -O1

### populate()

As I was analyzing it, I felt uneasy at block 9. I wasted a lot of my time because of that. Then I realized lenstr() is in a problematic state.

First of all, lesntr() returned size_t, but it can also return -INVALID_BUFF, which will wrap around to a huge +ve value.

Second, there was no error handling around lenstr() call. If it returned INVALID_BUFF, everything downstream will be disturbed.

I am not sure if this caused the uneasiness, as LLVM has to handle it. But I am glad that at least I've corrected the code now. I have made the function integer, and made changes everywhere it was called. Let's see how the IR is affected by this.

I have generated the IRs again, with these line stats:

| Source | C   | -O0  | -O1  | -O2  | -O3  |
| :----- | :-- | :--- | :--- | :--- | :--- |
| Old    | 311 | 1767 | 1198 | 1186 | 1186 |
| New    | 316 | 1795 | 1194 | 1182 | 1182 |

This function has truly driven me crazy. I was simply not able to comprehend how lenstr() and extendCap() was being inlined. I have wasted ~2h scrolling just because it was so boring. As I was approaching the end of the day, I was kinda hopeless nd already thinking about stopping reading this IR and now directly jump to the assembly tomorrow. But, this being is not trained like that. Running away was not an option, consciously, or subconsciously. I tried again, and boom. This time, I walked the function without even looking at the source, and got it done. Only thing is remained to be understood.

That's it.