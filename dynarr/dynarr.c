#include "dynarr.h"

DynArrStatus init(DynArr *arr, size_t elem_size, size_t cap){
  if (arr->capacity != 0) return ALREADY_INIT;

  if (elem_size == 0 || cap == 0) return INVALID_SIZES;
  if (cap > SIZE_MAX/elem_size) return SIZEMAX_OVERFLOW;

  void *ptr = malloc(cap * elem_size);
  if (!ptr) return MALLOC_FAILED;

  arr->ptr = ptr;
  arr->elem_size = elem_size;
  arr->capacity  = cap;
  arr->count = 0;

  return SUCCESS;
}

DynArrStatus extend(DynArr *arr, size_t add_bytes){
  if (!arr || arr->capacity == 0) return INIT_FIRST;
  if (arr->count+add_bytes <= arr->capacity) return SUCCESS;        // Works with add_bytes=0 as well

  size_t total = arr->count+add_bytes;
  size_t cap = arr->capacity;
  while (cap < total) cap *= 2;

  void *tmp = realloc(arr->ptr, cap*arr->elem_size);
  if (!tmp) return REALLOC_FAILED;

  arr->ptr = tmp;
  arr->capacity = cap;

  return SUCCESS;
}

DynArrStatus pushOne(DynArr *arr, const void *value){
  if (!arr || !arr->elem_size || !arr->capacity) return INIT_FIRST;

  if (arr->count+1 > arr->capacity){
    int res = extend(arr, 1);
    if (res != SUCCESS) return res;
  }

  void *dest = (char*)arr->ptr + (arr->count * arr->elem_size);
  memcpy(dest, value, arr->elem_size);
  arr->count++;

  return SUCCESS;
}

DynArrStatus pushMany(DynArr *arr, const void *elements, size_t count){
  if (!arr || !arr->elem_size) return INIT_FIRST;
  if (count == 0) return INVALID_COUNT;

  int res = extend(arr, count);
  if (res != SUCCESS) return res;

  void *dest = (char*)arr->ptr + (arr->count*arr->elem_size);
  memcpy(dest, elements, count*arr->elem_size);
  arr->count += count;

  return SUCCESS;
}

const void *getelement(const DynArr *arr, size_t idx){
  if (!arr || !arr->ptr) return NULL;
  if (boundcheck(0, arr->count, idx)) return NULL;

  return ((char*)arr->ptr + (idx * arr->elem_size));
}

size_t getarrlen(const DynArr *arr){ return arr->count; }

size_t getcap(const DynArr *arr){ return arr->capacity; }

DynArrStatus isempty(const DynArr *arr){ return (arr->count == 0) ? IS_EMPTY : ISNOT_EMPTY; }

int boundcheck(size_t lb, size_t ub, size_t idx){ return (idx >= lb && idx < ub); }

DynArrStatus setidx(DynArr *arr, const void *value, size_t idx){
  if (!arr || arr->count == 0 || arr->capacity == 0) return INIT_FIRST;
  if (boundcheck(0, arr->count, idx) != 1) return INVALID_IDX;

  void *dest = (char*)arr->ptr + (idx*arr->elem_size);
  memcpy(dest, value, arr->elem_size);
  return SUCCESS;
}

DynArrStatus bytecopy(const DynArr *main, DynArr *copy){
  if (!main || !copy || !main->ptr) return EMPTY_PTR;
  if (extend(copy, main->count) != SUCCESS) return REALLOC_FAILED;
  if (main->elem_size != copy->elem_size) return TYPES_DONT_MATCH;

  memcpy((char*)copy->ptr, main->ptr, main->count*main->elem_size);
  copy->count = main->count;
  return SUCCESS;
}

DynArrStatus merge(DynArr *arr1, const DynArr *arr2){
  if (!arr1 || !arr1->ptr || !arr2 || !arr2->ptr) return INIT_FIRST;
  if (extend(arr1, arr2->count) != SUCCESS) return REALLOC_FAILED;

  void *dest = (char*)arr1->ptr + arr1->count*arr1->elem_size;
  memcpy(dest, arr2->ptr, arr2->count*arr2->elem_size);
  arr1->count += arr2->count;

  return SUCCESS;
}

DynArrStatus export2stack(const DynArr *dynarr, void **stackarr){
  if (!dynarr || !dynarr->ptr) return INIT_FIRST;

  memcpy(*stackarr, dynarr->ptr, dynarr->count*dynarr->elem_size);
  return SUCCESS;
}

DynArrStatus insertidx(DynArr *arr, const void *value, size_t idx){
  if (!arr || !arr->ptr) return INIT_FIRST;
  if (arr->count == SIZE_MAX) return SIZEMAX_OVERFLOW;
  if (boundcheck(0, arr->count, idx) != 1) return INVALID_IDX;

  if (arr->count == arr->capacity){
    int res = extend(arr, 1);
    if (res != SUCCESS) return res;
  }

  void *dest = (char*)arr->ptr + (idx + 1)*arr->elem_size;
  void *src  = (char*)arr->ptr + idx*arr->elem_size;
  size_t bytes = (arr->count - idx)*arr->elem_size;
  memmove(dest, src, bytes);

  setidx(arr, value, idx);
  arr->count++;
  return SUCCESS;
}

DynArrStatus removeidx(DynArr *arr, size_t idx){
  if (!arr || !arr->ptr || arr->count == 0) return INIT_FIRST;
  if (boundcheck(0, arr->count, idx) != 1) return INVALID_IDX;

  void *dest = (char*)arr->ptr + idx*arr->elem_size;
  void *src = (char*)arr->ptr + (idx+1)*arr->elem_size;
  size_t bytes = (arr->count-idx-1)*arr->elem_size;
  memmove(dest, src, bytes);
  arr->count--;

  return SUCCESS;
}

// Array can be reused
DynArrStatus clearArr(DynArr *arr){
  if (!arr || !arr->ptr) return EMPTY_PTR;

  arr->ptr = NULL;
  arr->count = 0;
  arr->elem_size = 0;

  return SUCCESS;
}

// Deallocates the array
DynArrStatus freeArr(DynArr *arr){
  if (!arr->ptr) return EMPTY_PTR;

  free(arr->ptr);
  arr->ptr = NULL;
  arr->capacity = 0;
  arr->count = 0;
  arr->elem_size = 0;

  return SUCCESS;
}
