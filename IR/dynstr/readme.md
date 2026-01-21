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

As usual, everything is long and detailed. One interesting thing I found in boundcheck was a phi-node. Then I quickly opened the -O0 IR for dynarr.c and found that it is present there as well. So, nothing interesting.