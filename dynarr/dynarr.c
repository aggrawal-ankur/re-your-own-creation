#include "dynarr.h"

DynArrStatus init(DynArr* arr, size_t elem_size, size_t cap){
  if (!arr->capacity) return -ALREADY_INIT;
  if (elem_size == 0 || cap == 0) return -INVALID_SIZES;
  if (cap > SIZE_MAX/elem_size)   return -SIZEMAX_OVERFLOW;

  void* ptr = malloc(cap * elem_size);
  if (!ptr) return -MALLOC_FAILED;

  arr->ptr = ptr;
  arr->elem_size = elem_size;
  arr->capacity  = cap;
  arr->count = 0;

  return SUCCESS;
}

DynArrStatus extend(DynArr* arr, size_t add_bytes){
  if (!arr || !arr->ptr) return -INIT_FIRST;
  if (arr->count+add_bytes <= arr->capacity) return SUCCESS;        // Works with add_bytes=0 as well

  size_t total = arr->count+add_bytes;
  size_t cap   = arr->capacity;
  while (cap < total) cap *= 2;

  void* tmp = realloc(arr->ptr, cap*arr->elem_size);
  if (!tmp) return -REALLOC_FAILED;

  arr->ptr = tmp;
  arr->capacity = cap;

  return SUCCESS;
}

DynArrStatus pushOne(DynArr* arr, const void* value){
  if (!arr || !arr->ptr) return -INIT_FIRST;
  if (!value) return -INVALID_PUSHREQUEST;

  if (arr->count+1 > arr->capacity){
    int res = extend(arr, 1);
    if (res != SUCCESS) return res;
  }

  void* dest = (char*)arr->ptr + (arr->count * arr->elem_size);
  memcpy(dest, value, arr->elem_size);

  arr->count++;
  return SUCCESS;
}

DynArrStatus pushMany(DynArr* arr, const void* elements, size_t count){
  if (!arr || !arr->ptr) return -INIT_FIRST;
  if (!elements || count == 0) return -INVALID_PUSHREQUEST;

  int res = extend(arr, count);
  if (res != SUCCESS) return res;

  void* dest = (char*)arr->ptr + (arr->count*arr->elem_size);
  memcpy(dest, elements, count * arr->elem_size);

  arr->count += count;
  return SUCCESS;
}

int boundcheck(size_t lb, size_t ub, size_t idx){ return (idx >= lb && idx < ub); }

const void* getelement(const DynArr* arr, size_t idx){
  if (!arr || !arr->ptr) return NULL;
  if (boundcheck(0UL, arr->count, idx)) return NULL;

  return ((char*)arr->ptr + (idx * arr->elem_size));
}

int isempty(const DynArr* arr){ return (arr->count == 0) ? 0 : 1; }

DynArrStatus setidx(DynArr* arr, const void* value, size_t idx){
  if (!arr || !arr->ptr) return -INIT_FIRST;
  if (!value) return -INVALID_PUSHREQUEST;
  if (boundcheck(0UL, arr->count, idx) != 1) return -INVALID_IDX;

  void *dest = (char*)arr->ptr + (idx*arr->elem_size);
  memcpy(dest, value, arr->elem_size);
  return SUCCESS;
}

DynArrStatus mergedyn2dyn(const DynArr* src, DynArr* dest){
  if (!src || !src->ptr || !dest || !dest->ptr) return -INIT_FIRST;
  if (src->elem_size != dest->elem_size) return -TYPES_DONT_MATCH;

  int res = extend(dest, src->count);
  if (res != SUCCESS) return res;

  void* dptr = (char*)dest->ptr + dest->count*dest->elem_size;
  size_t bytes = src->count * src->elem_size;
  memcpy(dptr, src->ptr, bytes);

  dest->count += src->count;
  return SUCCESS;
}

DynArrStatus export2stack(const DynArr* dynarr, void** stackarr){
  if (!dynarr || !dynarr->ptr) return -INIT_FIRST;

  memcpy(*stackarr, dynarr->ptr, dynarr->count * dynarr->elem_size);
  return SUCCESS;
}

DynArrStatus insertidx(DynArr* arr, const void* value, size_t idx){
  if (!arr || !arr->ptr) return -INIT_FIRST;
  if (!value) return -INVALID_PUSHREQUEST;
  if (boundcheck(0UL, arr->count, idx) != 1) return -INVALID_IDX;

  if (arr->count == arr->capacity){
    int res = extend(arr, 1);
    if (res != SUCCESS) return res;
  }

  void* dest = (char*)arr->ptr + (idx + 1)*arr->elem_size;
  void* src  = (char*)arr->ptr + idx*arr->elem_size;
  size_t bytes = (arr->count - idx) * arr->elem_size;
  memmove(dest, src, bytes);

  setidx(arr, value, idx);
  arr->count++;

  return SUCCESS;
}

DynArrStatus removeidx(DynArr* arr, size_t idx){
  if (!arr || !arr->ptr) return -INIT_FIRST;
  if (boundcheck(0UL, arr->count, idx) != 1) return -INVALID_IDX;

  void* dest = (char*)arr->ptr + idx*arr->elem_size;
  void* src  = (char*)arr->ptr + (idx+1)*arr->elem_size;
  size_t bytes = (arr->count-idx-1)*arr->elem_size;
  memmove(dest, src, bytes);

  arr->count--;
  return SUCCESS;
}

DynArrStatus clearArr(DynArr* arr){
  if (!arr || !arr->ptr) return -INIT_FIRST;

  arr->ptr = NULL;
  arr->count = 0;
  arr->elem_size = 0;

  return SUCCESS;
}

DynArrStatus freeArr(DynArr* arr){
  if (!arr || !arr->capacity) return -INIT_FIRST;

  free(arr->ptr);
  arr->ptr = NULL;
  arr->capacity = 0;
  arr->count = 0;
  arr->elem_size = 0;

  return SUCCESS;
}
