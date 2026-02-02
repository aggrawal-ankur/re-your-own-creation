#ifndef DYNAMIC_ARR_H
#define DYNAMIC_ARR_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE_MAX (18446744073709551615UL)

// Container for dynamic arrays
typedef struct {
  void*  ptr;
  size_t elem_size;
  size_t count;
  size_t capacity;
} DynArr;

// Return status codes
typedef enum {
  SUCCESS,
  ALREADY_INIT,
  INVALID_SIZES,
  SIZEMAX_OVERFLOW,
  MALLOC_FAILED,
  INIT_FIRST,
  REALLOC_FAILED,
  INVALID_PUSHREQUEST,
  INVALID_IDX,
  TYPES_DONT_MATCH,
} DynArrStatus;

// Initialize the dynamic array
DynArrStatus init(DynArr* arr, size_t elem_size, size_t cap);

// Extend the capacity of an existing dynamic array
DynArrStatus extend(DynArr* arr, size_t required);

// Push one element to the end of the dynamic array (append)
// Caller must ensure type-correctness of the value to be pushed
DynArrStatus pushOne(DynArr* arr, const void* value);

// Push an array of elements to the end of the dynamic array (bulk-append)
// Caller must ensure type-correctness of the values to be pushed
DynArrStatus pushMany(DynArr* arr, const void* elements, size_t count);

// Function to check bounds
int boundcheck(size_t lb, size_t ub, size_t idx);

// Getter function to access the dynamic array ptr
const void* getelement(const DynArr* arr, size_t idx);

// Checks for empty dynamic arrays; -1 for empty && 0 for allocated
int isempty(const DynArr* arr);

// Function to set the element by indexing (same as array-subscripting)
// Caller must ensure type-correctness of the value
DynArrStatus setidx(DynArr* arr, const void* value, size_t idx);

// Insert element at an arbitrary index in the array
// Caller must ensure type-correctness of the value to be pushed
DynArrStatus insertidx(DynArr* arr, const void* value, size_t idx);

// Remove element at an arbitrary index in the array
DynArrStatus removeidx(DynArr* arr, size_t idx);

// Merge two dynamic arrays (arr2 is extended into arr1)
DynArrStatus mergedyn2dyn(const DynArr* src, DynArr* dest);

// Export a dynamic array to a stack-allocated array
DynArrStatus export2stack(const DynArr* dynarr, void* stackarr);

// Makes the array reusable
DynArrStatus clearArr(DynArr* arr);

// Deallocates the array
DynArrStatus freeArr(DynArr* arr);

#endif