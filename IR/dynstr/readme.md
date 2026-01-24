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

First of all, lenstr() returned size_t, but it can also return -INVALID_BUFF, which will wrap around to a huge +ve value.

Second, there was no error handling around lenstr() call. If it returned INVALID_BUFF, everything downstream will be disturbed.

I am not sure if this caused the uneasiness, as LLVM has to handle it. But I am glad that at least I've corrected the code now. I have made the function integer, and made changes everywhere it was called. Let's see how the IR is affected by this.

I have generated the IRs again, with these line stats:

| Source | C   | -O0  | -O1  | -O2  | -O3  |
| :----- | :-- | :--- | :--- | :--- | :--- |
| Old    | 311 | 1767 | 1198 | 1186 | 1186 |
| New    | 316 | 1795 | 1194 | 1182 | 1182 |

This function has truly driven me crazy. I was simply not able to comprehend how lenstr() and extendCap() was being inlined. I have wasted ~2h scrolling just because it was so boring. As I was approaching the end of the day, I was kinda hopeless nd already thinking about stopping reading this IR and now directly jump to the assembly tomorrow. But, this being is not trained like that. Running away was not an option, consciously, or subconsciously. I tried again, and boom. This time, I walked the function without even looking at the source, and got it done. Only thing is remained to be understood.

That's it.

---

While `populate` was successful in confusing me, the function itself was simple. However, one thing is worth calling out.
```
21:                                               ; preds = %19, %9
  %22 = phi i64 [ 0, %9 ], [ %20, %19 ]     ; WHY THIS
  ...
  ...
```

This is after the length is calculated and now we move forward in the logic. %20 is the computed and zero-extended (i64) length. The question is, why length must be zero if the control comes from block 9. Block 9 is where lenstr was inlined.

See, `!src` is already checked by `populate`, so `lenstr` logic starts from initializing `len=0`. Now the loop starts from str[1] up to len-1. str[0] was already checked in %18. Although LLVM could have reused the result from block 7 as well.

Anyways, if the string was empty, it would never reach the part where lenstr is inlined. Before the loop executes, the count is already 1. If the control to block 21 goes from the loop block, i.e block 12, the length is guaranteed to be >0. But if the control comes from block 9, that means src was null, that's why 0 is set in this case. It wasn't really a part of the code, but it is necessary to glue lenstr with populate properly.

### char2lcase()

This function is tiny, but it contains a very important thing. Before we go about analyzing the IR, let's see why how we can convert an alphabet to lowercase.

For ease, these are the different ASCII ranges for characters:

| Character | ASCII Decimal Range |
| :-------- | :------------------ |
| Control Characters (Non-printable) | 0-31 |
| Special printable characters | 32-47 |
| Decimal numbers (0-9) | 48-57 |
| Special printable characters | 58-64 |
| Uppercase (A-Z) | 65-90 |
| Special printable characters | 91-96 |
| Lowercase (a-z) | 97-122 |
| Special printable characters | 123-126 |
| Control Characters (Non-printable) | 125 |

First of all, this is only applicable to alphabets, so the ranges concerning us are:
```
uppercase: 65-90
lowercase: 97-122
```

There are two possible cases.
  1. The character is in lowercase already.
  2. The character is in uppercase.

We will start by checking the ASCII DECIMAL value of the character. If it falls in 97-122, we don't have to do anything. If it doesn't fall in 97-122, it falls in 65-90. That's when we have to do something.

Let's take `'A'`. A is 65. What we need is 96. Is there any connection between 65 and 96? The difference b/w them is 32, which is a power of 2. Let's take their binary representation. As we are unsigned territory, we'll go with 1s complement.
```
A => 65 => 1000001
a => 97 => 1100001
```
1. Both require 7 bits to be represented.
2. Both have the MSB on.

If I add 32 to 65, I get 97, exactly what we needed.

Let's take another character: `'G'`. It is 71. Add 32, we get 103, exactly what we needed. That's how it'd look like in binary:
```
G => 71  => 1000111
g => 103 => 1100111
```

If we notice the bit-patterns, we can ses that the lower bits are the same for both the uppercase and the lowercase versions of the character. What's missing in the uppercase version is the bit that gives 32 is off. If we can turn that on, we are good to go.

So, all we need to do is:
```c
(_char | 32)
// or
(_char | 0x20)
```
That's exactly what we are doing.

---

Let's see how the IR is doing it at -O1.

```
define dso_local signext i8 @char2lcase(i8 noundef signext %0) local_unnamed_addr #6 {
  %2 = add i8 %0, -65
  %3 = icmp ult i8 %2, 26
  %4 = or disjoint i8 %0, 32
  %5 = select i1 %3, i8 %4, i8 %0
  ret i8 %5
}
```

We are subtracting 65 from the character's ASCII DECIMAL value, why! Then we are comparing it 26, which is the total number of alphabets in English, why! Then we take a disjointed OR, that's something new. Last, we decide which value to return based on the comparison. Too much is happening here. Let's slow down.

At first glance, we can see that %5 is where we are deciding which is the correct return, %0 (that means, it is already in lowercase) or %4 (the transformed version). Also, %4 is not affected by %3. Let's start with %4.

Standard bitwise OR is simple. 1 if any of the operands have 1 and 0 if both the operands are 0. Disjointed bitwise OR is no different. What's different this time is that both the operands are assumed to have disjoint bit-pattern. That is, *in both the operands, there is no bit position which can have both 1*. Take this example:
```
%a = 1010
%b = 0100
```
(%a, %b) are disjoint here.

If you notice:
```
add(1010, 0100) = or disjoint(1010, 0100)
```

This is not true with plain bitwise OR, as the assumption that *both the operands have such a bit-pattern that no bit-position is ON in both the operands* is missing. We can have cases like:
```
   1010
   0110
=> 10000
```
See, we had a overflow here. Disjointed OR ensures that there will no overflow. If it occurs, the value will be poisoned.

---

*That means, the compiler calculated that the operands are disjoint here? How?*

First of all, the operands are %0 and 32. While we are analyzing how we can convert an alphabet to lowercase, we've noticed that no uppercase character (65-90) has the bit that gives 32 ON. And, 32 is all we have to add to an uppercase character. You noticed something? 32 itself has the only bit ON which is the only bit that is always OFF in all the uppercase characters. That's a disjoint pair of values.

If it is hard to visualize that, we can use this tiny program to print the binary representation of a number:
```py
def convert_decimal_to_binary():
  try: 
    binary_num = bin(decimal_num)[2:]
    print(f"The binary representation of {decimal_num} is: {binary_num}")
  except ValueError:
    print("Please enter a valid integer.")

for i in range(65, 65+26):
  convert_decimal_to_binary(i)

convert_decimal_to_binary(32)
```

---

Now, what do we get by subtracting 65 from the character's ASCII DECIMAL value?
```
'A' => 65-65 => 0
'B' => 66-65 => 1
.
'Y' => 89-65 => 24
'Z' => 90-65 => 25
```

We get a value which follows this: `[0, 26)`. 26 alphabets, starting from 0, ending at 25. Does anything else follow this?
```
* => 42-65 => -23
6 => 54-65 => -11
^ => 94-65 =>  29
f => 102-65 => 37
```
Nothing else follows this.

---

So, what's happening is that we subtract 65 from the character's ASCII DECIMAL value, check if the result is in `[0, 26)`, take a disjoint bitwise OR of the character's original ASCII DECIMAL value with 32 and return the result accordingly. Nice.

### char2ucase()

Let's try ourselves first.

These are our ranges:
```
uppercase: 65-90
lowercase: 97-122
```

Now the characters from 97-122 are required to be converted into 65-90. The difference is again 32. If we subtract 32 from any character falling in 97-122, we'll get the lowercase representation of that alphabet.

Take this example:
```
'A' => 97
'a' => 65
97-32 = 65
```

But how we will do this bitwise? Take these examples:
```
'A' => 97 => 1100001
'a' => 65 => 1000001

'D' => 100 => 1100100
'd' => 68  => 1000100
```

In both the cases, the bit that adds 32 is OFF. That's all we need to do. And we can use bitwise AND for this task.

We have to take bitwise AND with ~0x20 or -33. Since -33 is a signed value, we have to use 2s complement.
```
'A' => 000000000 1100001
-33 => 111111111 1011111
       000000000 1000001
```

---

Let's see how the IR does it.
```
define dso_local noundef signext i8 @char2ucase(i8 noundef signext %0) local_unnamed_addr #6 {
  %2 = add i8 %0, -97
  %3 = icmp ult i8 %2, 26
  %4 = and i8 %0, 95
  %5 = select i1 %3, i8 %4, i8 %0
  ret i8 %5
}
```

We start by subtracting 97 and checking if it falls within `[0, 26)`. Then we take bitwise AND with 95, that's a different method. Let's see why that works.
```
95 =>            1011111
-33 => 111111111 1011111
```

I hope it is clear.

---

These conversion functions were nice. ***When you explore the problem yourself, and find a solution that works properly, suddenly every other solution starts to make sense without much effort.***

### islcase() and isucase()

Same logic as char2lcase and char2ucase.

### tolcase()

Pretty straightforward. It just combines copystr, char2lcase, and islcase. However, I've noticed two things.

1. For some reason, I felt that exportdyntobuff is basically copystr. When I checked, it indeed is. exportdyntobuff only makes the first argument a dynamic string. That's it.
2. This line: `lcase[i] = '\0';` in copystr in unnecessary as copystr itself appends the null-character to the end of the buffer.

I am gonna remove these things.

After changes, the stats are:

|     | Lines |
| :-- | :---- |
| C   | 308   |
| -O0 | 1750  |
| -O1 | 1155  |

### toucase()

I've to remove the null-terminator line here as well. So the IR reduced again. Now it is at 1148 lines.

The function follows the same pattern as tolcase.

### cmp2strs()

This instruction needs reordering:
```c
if (!str1 || !str1->data|| !str2->data || !str2 ) return -INVALID_DPTR;
// to
if (!str1 || !str1->data || !str2 || !str2->data) return -INVALID_DPTR;
```

2 new lines added, 1150.

What made me do this was again the IR. I saw inconsistent icmp and load. This forced me to see the source as now I am avoiding to look at the source while reading the IR. I am doing this since islcase. It is nice this way.

---

I started this IR with a question that why clang prioritizes branching over `or` in cases like these:
```c
if (!str1 || !str2)
```
clang doesn't check !str1 and !str2 and then evaluate a bitwise OR between them. Instead, first it evaluates !str1, then it branches based on the evaluation and then it checks !str2. This behavior is questionable but I didn't questioned it during `dynarr.c`.

Then a thought came to my mind that I should read this IR first. I'll get my answer.

Have a look at this:
```
5:                                                ; preds = %3
  %6 = load ptr, ptr %0, align 8, !tbaa !11   ; str1.data
  %7 = icmp ne ptr %6, null   ; !str1.data
  %8 = icmp ne ptr %1, null   ; !str2
  %9 = and i1 %8, %7
  br i1 %9, label %10, label %128
```

Now take this from extendCap:
```
define dso_local range(i32 -5, 1) i32 @extendCap(ptr noundef %0, i64 noundef %1) local_unnamed_addr #2 {
  %3 = icmp eq ptr %0, null       ; !str
  br i1 %3, label %21, label %4

4:                                                ; preds = %2
  %5 = load ptr, ptr %0, align 8, !tbaa !11
  %6 = icmp eq ptr %5, null       ; !str.data
  br i1 %6, label %21, label %7
```
The semantics are the same, but clang used `eq` and branching instead of `ne` and `and`. What can be the reason?

I've noticed something when I opened the C-source. `!str` and `!str->data` have `str` in common. `!str->data` is only possible when `str` is defined. Maybe that's the reason we can't use `and` and we have rely on branching to evaluate the validity of the object pointer before we access it's members?

Based on the above understanding, cmp2strs make perfect sense because `and` is happening between `str1->data` and `str2`. The pointers are different.

---

Locked in, finished in one go.