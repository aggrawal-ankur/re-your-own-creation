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

### pushMany

pushMany is similar to pushOne. `extend` is inlined here as well.

### *getelement

`*getelement` is simple too. Only this instruction:
```c
if (idx >= arr->count)
```
... is inverted.
```
%10 = icmp ugt i64 %9, %1
```
where %9 is arr->count and %1 is idx.

-O1 checks (arr->count > idx), instead of (idx >= arr->count). The reason is strict comparison. We know it already.

### getarrlen and getcap

These are basic functions, so, nothing interesting.

### isempty

This function is interesting as it involves ternary operator.

What we are looking for is:
```
%5 = select i1 %4, i32 -8, i32 -9
```
%4 is the result of the comparison. If true, return -8 (IS_EMPTY). If false, return -9 (ISNOT_EMPTY)

### bouncheck

boundcheck() is also simple. The compiler kept uge and ult as it is, without transforming uge to something else, which is quite shocking. The reason can be the inherent complexity of the expression. The compiler can't reduce it to something else without keeping the intent intact, so it avoided!

The interesting part is this:
```
%7 = zext i1 %6 to i32
```
Why zero-extend? I used int as the return type, not size_t.

### setidx

This one is interesting. It uses both `isempty` and `boundcheck`. And they are inlined. When functions get inlined, the interesting part is ***how the ends are glued with the original function***.

Block 3 resembles isempty. It checks whether arr->count is 0 or not. Although the return value is not confirmed yet.

Block 7 is the next interesting part. There is a ugt comparison between %5 and %2. %5 is the arr.count and %2 is the idx. Notice, arr.count is passed as the second arg to boundcheck, which is why it is `ub` to it.

We are only checking `ub > idx`, what about (idx >= lb). Notice, `lb` is always set to 0. That means, idx is unsigned. So, there is no point of checking that.

Block 15 is where we set the return value.

***Remember, 0 makes the difference here. Plus, assumptions is a big part of this. idx is size_t, but if you put a ssize_t value, that is a different scenario, and since we are not allowing a ssize_t, that would lead to an undefined behavior.***

### bytecopy

We start with this:
```c
if (!main || !copy || !main->ptr);
```
If either of the containers are uninitialized or the first container is initialized but empty, return.

We achieved it by logical-OR. But the IR uses a different approach.

It checks nullability of main and copy, and performs a logical-and on the output.
  - %3 and %4 will contain 1 if both the pointers aren't NULL. Only in this case, we will branch to block 6.
  - If either of %3 and %4 are NULL, we'll directly jump to the return part.

***Same intent, different expression.***

---

Now, extend is inlined once again, starting from block 6.

### merge, export2stack

Same as before.

### removeidx

Block 2: `!arr`.

Block 4: `!arr.ptr`.

Block 7:
  - %9 is `arr.count`.
  - %10 is for boundcheck. %1 is the idx we are checking for.

Block 11 is the interesting piece here. It is involving a lot of calculations, so I'd take a clear approach here.

%0  -> arr
%5  -> arr.ptr
%9  -> arr.count
%13 -> arr.elem_size
%14 -> mul(%13, %1) -> arr.elem_size * idx
%15 -> &(%5[%14])
%16 -> (idx+1)
%17 -> mul(%13, %16) -> (idx+1)*arr.elem_size
%18 -> &(%5[%17])
%19 -> xor(%1, -1) -> xor(idx, -1) -> -(idx-1)
%20 -> add(%9, %19) -> add(arr.count, -(idx-1)) -> arr.count-idx-1
%21 -> mul(%13, %20) -> arr.elem_size * (arr.count -idx -1)

call memmove with %15 as the dest, %18 as the src and %21 as the total bytes required.

%22 and %23 -> arr->count--

---

Now the insight:

The xor instruction was this:
```
x ^ -1 == ~x == -(x+1)
```
This is universally true.

What is not universally true is:
```
x ^ -n == ~x == -(x+n)
```

---

At first, I was glossing over it, because it was similar to the previous bits, except the arithmetic chaos. Then I noticed the xor. That's when I decided I can't gloss.

This is a great example to understand *to what extent, the compiler can go, to preserve the original intent, in the most computationally efficient and canonical way possible.*

The compiler's expression of the intent was kind of coupled with the author's expression. Or, I was reading the IR alongside the source, which is why I was able to understand both easily. ***I must not confuse it with the fact that these can be magnitudes apart in reality.***

## -O2

The first notable change is the presence of load, gep, and phi-nodes.

| Opt-Level | load | gep | phi-nodes |
| -O1       | 77   | 52  | 23        |
| -O2       | 75   | 49  | 32        |

The -O1 file is spanned across 685 lines, and -O2 across 684. Not much of a difference. But don't get fooled by it. There are differences, subtle ones. And that's exactly the challenge. Most of the stuff is identical. But I'll do it anyways.

---

### init()

100% identical with -O1.

### extend()

100% identical with -O1.

### pushOne()

It starts same but starts to differ from the branching decision of block 8.

At -O1, it is fairly simple:
```
br i1 %14, label %15, label %30
```
Branch to %15, if extension required. Else, %30.

At -O2, the decision-making is different.
```
br i1 %14, label %17, label %15
```

If extension required, branch to 17. Else, 15.

Block 17 of -O2 starts identical to block 15 of -O1.

Block 15 of -O2 is this:
```
15:                                               ; preds = %8
  %16 = load ptr, ptr %0, align 8, !tbaa !11
  br label %31
```
Notice, we are making an unconditional jump to block 31. From this, we can infer that block 31 is where the real code for pushOne starts. Everything before is extend, starting from block 17.

Everything is identical starting from block 17. Block 28 is where it breaks. These are 2 extra loads, while -O1 didn't have those:
```
28:                                               ; preds = %23
  store ptr %26, ptr %0, align 8, !tbaa !11
  store i64 %20, ptr %12, align 8, !tbaa !5
  %29 = load i64, ptr %9, align 8, !tbaa !13
  %30 = load i64, ptr %5, align 8, !tbaa !12
  br label %31
```

%9 is a ptr to `arr.count` and %5 is a ptr to `arr.elem_size`.

It looks confusing, but block 31 clears everything perfectly. It starts with 3 phi-nodes.
```
%32 = phi i64 [ %6, %15 ], [ %30, %28 ]
%33 = phi i64 [ %10, %15 ], [ %29, %28 ]
%34 = phi ptr [ %16, %15 ], [ %26, %28 ]
```
All of them decides on %15 and %28.

The control branches to block 15 only if extension is not required, and then redirect to block 31, like a trampoline. You may ask, why block 15 even exist. That question will be answered soon.

Block 28 is where extend ends.

Looking at the source:
```c
void *dest = (char*)arr->ptr + (arr->count * arr->elem_size);
memcpy(dest, value, arr->elem_size);
arr->count++;
```
... we can notice that we need three variables for memcpy to work. They are arr->(ptr, count, elem_size). Those 3 phi-nodes are exactly about that.

  1. %6 is the elem_size, %10 is the count and %16 is the ptr. elem_size and ptr are prone to change if realloc was called in extend.
  2. %30 has the new elem_size value as it reloads the ptr. %29 is the count. I am not sure why it is not reused from %10. %26 is the new ptr.

---

I think that the use of phi-nodes is the only notable optimization here.

### pushMany()

It starts identical with -O1 and goes similar to pushOne. Block 18 or %19 loads arr->ptr and branches unconditionally to block 32. extend is inlined block 20 on wards.

Similarly, block 29, where extend ends, have two extra load stmts.

At block 32, we have 3 phi-nodes, for deciding which version of ptr, count and elem_size to use.

Overall, it was just like pushOne.

### *getelement getarrlen, getcap, isempty, boundcheck and setidx

100% identical with -O1.

### bytecopy()

Fully identical except one line. -O2 reuses %16 in block 38 while -O1 has an extra gep for that.

### merge()

It starts identical, then deviate starting from block 33. But the pattern is identical with the previous functions.

One thing I am not able to understand is why the compiler is not reusing certain values. Take this example:
```
27:                                               ; preds = %23
  %28 = getelementptr inbounds i8, ptr %0, i64 8
  %29 = load i64, ptr %28, align 8, !tbaa !12
  ....

37:
  %42 = getelementptr inbounds i8, ptr %0, i64 8
  %43 = load i64, ptr %42, align 8, !tbaa !12
```
And this is not the first time. We've noted this previously as well.

### export2stack

100% identical with -O1.

###