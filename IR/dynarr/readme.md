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

### init()

Starting with init(), the function declaration is a little different.
```bash
# At -O0
define dso_local i32 @init(ptr noundef %0, i64 noundef %1, i64 noundef %2) #0

# At -O1
define dso_local range(i32 -7, 1) i32 @init(ptr nocapture noundef %0, i64 noundef %1, i64 noundef %2) local_unnamed_addr #0
```

The important thing here is the `range(a, b)` attribute. The actual range is `[a, b)`, which is the range possible values the return parameter can have. What it can be used for? It is excellent for "dead code elimination".

Take this: if a function returns a value in the range of [0, 10) and the caller has a conditional check that checks if the returned value is greater than 20, that's an example of "dead code", which can be eliminated.

From this, we can learn that if we are exploring an unknown binary, its disassembly can't be assumed to have one-to-one correspondence with source because instructions might have been removed or optimized. For example: a multiplication by a value in power of 2 can be optimized with bitwise shifts.

---

All the alloca(s) have vanished. That's a signal for mem2reg.

---

-O1 performs the initial checks a little differently. It uses `llvm.umul.with.overflow.i64`, which is more optimized and safe than the standard `ugt` check.

It returns a pair of values, like this: `(res, overflow_occurred)`. The `extractvalue` extracts the overflow check. If overflow occurred (1), branch to %17 (return). Else, %6.

Instead of checking by division, we used multiplication. If the multiplication of cap and elem_size overflows, we get the same results downstream.

Clang prioritized multiplication over division multiplication involves less cycles than division, thus comes cheaper. But cost is only one reason.

Multiplication was more safer than division here.

Now we extract the 24-31 bytes in the DynArr struct passed in %0. These bytes are `arr->capacity`.

***Remember, intent is what matters at the end of the day. If the toolchain finds an efficient way to get the same downstream results, it will give preference to it at higher optimization levels. Therefore, what's visible in the final binary preserves the author's intent 100%, but it doesn't guarantees the intent will be preserved as per the author with 100% exactitude.***

---

The next noticeable difference is the return strategy.

There are 4 returns in total. -O0 takes the simplest approach. It has already allocated a slot on stack for the return value, which is %4. That slot is populated every time a probability for return arises.

That's why -O0 has 4 separate branches just for exit.
```
13:                                               ; preds = %3
  store i32 -6, ptr %4, align 4
  br label %40    ; exit

19:                                               ; preds = %14
  store i32 -7, ptr %4, align 4
  br label %40    ; exit

27:                                               ; preds = %20
  store i32 -1, ptr %4, align 4
  br label %40    ; exit

28:
  ...
  store i32 0, ptr %4, align 4
  br label %40

40:                                               ; preds = %28, %27, %19, %13
  %41 = load i32, ptr %4, align 4
  ret i32 %41
```
Each branch involves a store operation.

On the contrary, -O1 uses phi-nodes, which collapses these branches like this:
```
17:                                               ; preds = %14, %10, %6, %3
  %18 = phi i32 [ -6, %3 ], [ -7, %6 ], [ 0, %14 ], [ -1, %10 ]
  ret i32 %18
```

phi-nodes decide the right value based on where this branch received the control from.

### extend()

The first line:
```c
if (!arr || !arr->capacity) return INIT_FIRST;
```
... is broken in across 2 branches, i.e %2 and %4. I expect that the phi-nodes must have the same return value for both these branches, which is true.
```
25:                                               ; preds = %24, %17, %8, %2, %4
  %26 = phi i32 [ -3, %4 ], [ -3, %2 ], [ 0, %8 ], [ 0, %24 ], [ -4, %17 ]
  ret i32 %26
```
%4 and %2, both return -3, i.e INIT_FIRST.

---

Block 13 is special because it's a loop.
```
13:                                               ; preds = %8, %13
  %14 = phi i64 [ %16, %13 ], [ %6, %8 ]
  %15 = icmp ult i64 %14, %11
  %16 = shl i64 %14, 1
  br i1 %15, label %13, label %17, !llvm.loop !14
```
When I read %14, I was immediately perplexed how this is going to work. The only block that branches to %13 is %8. But when I had a close look on the source, I realized what it is.
```c
while (cap < total) cap *= 2;
```
For the first run, %13 receives control from %8. Later, it's the loop that branches %13 to %13.

Notice that `cap *= 2` is represented as a left shift bitwise operation.

Everything else is simple, except one thing.

---

Take these two instructions:
```c
if (arr->count+add <= arr->capacity) return SUCCESS;
while (cap < total) cap *= 2;
```

Now the IR:
```
%12 = icmp ugt i64 %11, %6    ; %11: cap and %6:  arr->count+add
%15 = icmp ult i64 %14, %11   ; %11: cap and %14: total
```

Both operations involves "less than", but why only `while (cap < total)` got ult, but the former one got ugt?

LLVM prefers strict comparisons, which avoid equality checks as they are handled via control flow or negation. This simplifies analysis.

### pushOne

pushOne started normal, but evolved into a form I wasn't ready for.

Block 15 is where things start to get complicated. It looks normal, a equality check with 0. But where in the source that check is happening? In pushOne, it is:
```c
if (res != SUCCESS) return res;
```
... but there is no call to `extend` yet. Then how can this be `res`?

As I looked down, I saw inlining happening for the first time. Blocks 17, 21 and 26 are completely replicas of the ones found in extend's IR.

Block 15 and 27 are the most confusing parts here. The reason is, it glues extend with pushOne.

Let's start with block 15.
  - extend starts with this: `if (!arr || !arr->capacity)`.
  - If you notice, we have already check `!arr` as the first thing in pushOne. There is no need to repeat that.
  - We only have to check `if (!arr->capacity)`.
  - If you see what is %13, it refers to bytes 24-31 in the struct ptr %0, which is the capacity member.

Block 15 is how `extend` started to exist inside pushOne.

Block 17 is a loop. But extend has one more line: `if (arr->count+add <= arr->capacity)`, and that is missing.

Have a look at %19.
```
%19 = icmp ult i64 %18, %11
```
%18 must be `cap` and %11 must be `total`.

`total` is just `arr.count+add`. add is 1 here, as 1 is passed to extend. Now notice this line: `if (arr->count+1 > arr->capacity){` in pushOne. Therefore, %11 is our `total`.

%13 is our initial capacity.

Still,
```c
if (arr->count+add <= arr->capacity) return SUCCESS;
```
... is missing.

If you notice,
```c
if (arr->count+1 > arr->capacity)
```
... is exactly the opposite of that condition. That's redundant now, so clang removed it. Simple.

Now comes block 27. There are two virtual registers with similar phi-nodes. These phi-nodes are for this block of code:
```c
if (arr->count+1 > arr->capacity){
  int res = extend(arr, 1);
  if (res != SUCCESS) return res;
}
```
%28 is used as a deciding factor, whether the remaining body should execute or not and %29 is the actual return value from the function call.

***pushOne is a another example that proves that the final disassembly, or even codegen assembly, may or may not resemble the way author exactly wrote it. But the intent will be intact.***
