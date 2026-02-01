# Changelog

These changes to dynarr.c were made on **January 31, 2026** when I was stuck at bytecopy, merge and export2stack as they were doing the same thing, which triggered this.

I was too exhausted to write this changelog on the same day so I am writing it in the morning of **February 01, 2026**.

As I was changing things, I realized that a changelog is worth it to learn some things.

# #1 Unnecessary defensive posture!

I am talking about stuff like this:
```c
DynArrStatus pushOne(DynArr *arr, const void *value){
  if (!arr || !arr->elem_size || !arr->capacity) return INIT_FIRST;
  ...
}
```
This is not wrong but not required either. All I should check is whether the pointer to the dynamic array struct is valid and the `arr->ptr` is malloc-ed (initialized). Rest should be in place already.

# #2 Why do we even check !arr?

We do this to check the validity of the pointer.

This is `if (!arr)`:
```c
if (arr == NULL) return;
```

This is `if (ptr)`:
```c
if (arr != NULL){
  // do this stuff
}
```

---

For normal numbers, use `count == 0` notation, not `!count`.

# #3 Unnecessary checks in place and Necessary checks missing!

extend reallocates the pointer, the valid check should only be about `!arr || !arr->ptr`. There is no need for checking the capacity separately. But I never check if `!arr->ptr` is valid.
```c
DynArrStatus extend(DynArr *arr, size_t add_bytes){
  if (!arr || arr->capacity == 0) return INIT_FIRST;
  ...
}
```

---

This is another case:
```c
DynArrStatus pushOne(DynArr *arr, const void *value){
  if (!arr || !arr->elem_size || !arr->capacity) return INIT_FIRST;
  ...
}
```

Where it should be:
```c
DynArrStatus pushOne(DynArr* arr, const void* value){
  if (!arr || !arr->ptr) return -INIT_FIRST;
  if (!value) return -INVALID_PUSHREQUEST;
  ...
}
```
I missed checking the validity of the `value` ptr.

# #4 Pointer declaration drama!

I don't know which video spawned this confusion in me but let's leave that.

I've always used `void *ptr` but for some reason that I didn't understood well in the video, I thought `void* ptr` is better. Let's dissolve this confusion.

When I declare one single variable, there is no difference between:
```c
int* ptr;
int *ptr;
int * ptr;
```
... all declare a pointer-to-int.

When I club multiple variables in one line, that's where the problem is. The interpretation can get wrong.

Case 1:
```c
int *ptr, num;
```
It declares a pointer-to-int (ptr) and an integer num.

Case 2:
```c
int* ptr, num;
```
It declares a pointer-to-int (ptr) and an integer num. But it can be misinterpreted as two variables of pointer-to-int type.

In both the cases, interpretation is where it becomes confusing, not the meaning.

# #4 Error enum usage.

I was using this kind:
```c
enum {
  FIRST=-1,
  SECOND=-2,
}
```

When I could do this:
```c
enum {
  FIRST,
  SECOND,
}

if (cond) return -FIRST;
```
I saw this when I was reading fs/binfmt_elf.c in torvalds/linux.

# #5 Removed 3 fns.

getarrlen and getcap don't make sense to me, so I removed them.

bytecopy and merge were almost similar, so I've removed bytecopy as well and renamed merge to mergedyntodyn.

# #6 boundcheck arg1

Since boundcheck expects `lb` in size_t and numbers without any variable are integers by default, this triggers zero-extension, which is harmless in case of zero, but the practice itself feels wrong because signed values operate differently.

I should better follow what boundcheck expects and pass 0 as a UL.
```c
if (boundcheck(0UL, arr->count, idx) != 1) return -INVALID_IDX;
```

# #7 mergedyntodyn (or merge) conflict

The source was confusing. I couldn't identify which is the source and which is the destination, even though one was `const` and I never looked at that information. So I changed from (arr1, arr2) t0 (src, dest).

---

Done. Now I can focus back on x64-asm.