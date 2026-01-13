#ifndef DYNAMIC_ARR_H
#define DYNAMIC_ARR_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE_MAX (18446744073709551615UL)

// Container for dynamic arrays
typedef struct {
  void *ptr;
  size_t elem_size;
  size_t count;
  size_t capacity;
} DynArr;

// Return status codes
typedef enum {
  SUCCESS=0,
  MALLOC_FAILED=-1,
  EMPTY_PTR=-2,
  INIT_FIRST=-3,
  REALLOC_FAILED=-4,
  INVALID_IDX=-5,
  SIZEMAX_OVERFLOW=-6,
  ALREADY_INIT=-7,
  IS_EMPTY=-8,
  ISNOT_EMPTY=-9,
  TYPES_DONT_MATCH=-10,
} DynArrStatus;

// Initialize the dynamic array
DynArrStatus init(DynArr *arr, size_t elem_size, size_t cap);

// Extend the capacity of an existing dynamic array
DynArrStatus extend(DynArr *arr, size_t required);

// Push one element to the end of the dynamic array (append)
DynArrStatus pushOne(DynArr *arr, const void *value);

// Push an array of elements to the end of the dynamic array (bulk-append)
DynArrStatus pushMany(DynArr *arr, const void *elements, size_t count);

// Merge a VLA (stack-allocated) in a dynamic array
#define mergeVLA pushMany;

// Getter function to access the dynamic array ptr
const void *getelement(const DynArr *arr, size_t idx);

// Getter function to access the dynamic array element count
size_t getarrlen(const DynArr *arr);

// Getter function to access the dynamic array capacity
size_t getcap(const DynArr *arr);

// Checks for empty dynamic arrays; -1 for empty && 0 for allocated
DynArrStatus isempty(const DynArr *arr);

// Function to check bounds
int boundcheck(size_t lb, size_t ub, size_t idx);

// Function to set the element by indexing (same as array-subscripting)
DynArrStatus setidx(DynArr *arr, const void *value, size_t idx);

// Perform deep copy of dynamic array into another dynamic array
DynArrStatus bytecopy(const DynArr *main, DynArr *copy);

// Merge two dynamic arrays (arr2 is extended into arr1)
DynArrStatus merge(DynArr *arr1, const DynArr *arr2);

// Export a dynamic array to a stack-allocated array
DynArrStatus export2stack(const DynArr *dynarr, void **stackarr);

// Insert element at an arbitrary index in the array
DynArrStatus insertidx(DynArr *arr, const void *value, size_t idx);

// Remove element at an arbitrary index in the array
DynArrStatus removeidx(DynArr *arr, size_t idx);

// Makes the array reusable
DynArrStatus clearArr(DynArr *arr);

// Deallocates the array
DynArrStatus freeArr(DynArr *arr);

#endif