# Reading the LLVM IR for dynarr.c

## -O0

```bash
clang -S -emit-llvm -O0 dynarr.c -o O0.ll
```

At -O0, everything is explicit and predictable. Nothing is optimized in any way. Front allocas, straight arithmetic operations, everything as per the C-source only.

The IR is 1044 lines long. Comparing to our source, which is 170 lines long, this is decent and expected, as there is not much (or anything, basically) that is happening here.

## -O1

```bash
clang -S -emit-llvm -O1 dynarr.c -o O1.ll
```

Now the IR is reduced to 685 lines. That's a sharp 359 lines reduction. Let's find out what has changed.

The first immediately noticeable change is in the attributes.
  - `optnone` is gone, which means, we can expect optimizations. But, remember, we've only jumped from -O0 to -O1, so there will not be heavy optimizations. Alignment with the source is still a priority.
  - `norecurse nosync` is introduced, which is a signal that the compiler is making itself sure of what the code is not.
  - The compiler is being aggressive about `willreturn memory`, which provide info about memory access patterns.
  - Other attributes like `mustprogress nofree nounwind nosync` are also flooded.

---

Starting on the with actual function, the function declaration is a little different.
```bash
# At -O0
define dso_local i32 @init(ptr noundef %0, i64 noundef %1, i64 noundef %2) #0

# At -O1
define dso_local range(i32 -7, 1) i32 @init(ptr nocapture noundef %0, i64 noundef %1, i64 noundef %2) local_unnamed_addr #0
```

The important thing here is the `range(a, b)` attribute. The actual range is `[a, b)`, which is the range possible values the return parameter can have. What it can be used for? It is excellent for "dead code elimination".

Take this: if a function returns a value in the range of [0, 10) and the caller has a conditional check that checks if the returned value is greater than 20, that's an example of "dead code", which can be eliminated.

From this, we can learn that if we are exploring an unknown binary, its disassembly can't be assumed to have one-to-one correspondence with source because instructions might have been removed or optimized. For example: a multiplication by a value in power of 2 can be optimized with bitwise shifts.