#ifndef DYNSTR_CORE_H
#define DYNSTR_CORE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

// Return codes
typedef enum {
  SUCCESS,
  INIT_ALREADY,
  INVALID_CAP,
  MALLOC_FAILED,
  INIT_FIRST,
  REALLOC_FAILED,
  INVALID_BUFF,
  INVALID_IDX,
  INVALID_RANGE,
  NOT_LCASE,
  NOT_UCASE,
  TOLCASE_FAILED,
  TOUCASE_FAILED,
  STRS_NOT_EQUAL,
  CMP_FAILED,
  KMP_RES_INVALID,
  SUBSTR_NOT_FOUND,
  CHAR_NOT_FOUND,
} DynStrStatus;

// Dynamic string struct
typedef struct {
  char*  data;
  size_t len;   // doesn't include \0
  size_t cap;   // including \0
} DynString;

// Struct for holding KMP search result
typedef struct {
  size_t  count;
  size_t* indices;
} kmp_result;

/* Functions */

// Initialize the dynamic string
DynStrStatus init(DynString* str, size_t capacity);

// Calculates the length of a string (doesn't include '\0')
int lenstr(const char* str);

// Copy a buffer (stack, heap or just another dynamic string) into a dynamic string
DynStrStatus populate(DynString* dest, const char* src);

// Verify an idx against a set of bounds
int boundcheck(size_t lb, size_t ub, size_t idx);

// Returns a pointer to the dynamic string (only declare a ptr variable in the callee, no buffer required)
DynStrStatus getstr(const DynString* str, size_t idx, char** out);

// Slice a dynamic string and copy it in a callee allocated buffer
DynStrStatus getslicedstr(const DynString* str, size_t start, size_t end, char* outstr);

// Compare two dynamic strings
DynStrStatus cmp2strs(const DynString* str1, const DynString* str2, int sensitivity);

// Clear and mark a dynamic string to be reused again (capacity intact)
DynStrStatus clearStr(DynString* str);

// Deallocate the dynamic string completely (release the capacity)
DynStrStatus freeStr(DynString* str);

// Convert a string to lowercase (lcase must be callee-allocated)
DynStrStatus tolcase(const char* str, char* lcase);

// Convert a string to uppercase (ucase must be callee-allocated)
DynStrStatus toucase(const char* str, char* ucase);

// Check if a string is lowercase
DynStrStatus islcase(const char* str);

// Check if a string is uppercase
DynStrStatus isucase(const char* str);

// Returns the number of occurrences of a character
DynStrStatus findchar(const char* str, char c, int sensitivity, int* count);

// Perform Knuth-Morris-Pratt (KMP) search to find a substring in a string
DynStrStatus kmp_search(const char* str, const char* pat, kmp_result* kmp_obj);

// (Run kmp_search before) Checks the presence of a substring in a string
DynStrStatus isin(kmp_result* kmp_res);

// (Run kmp_search before) Sets idx with the first occurrence of a substr, else -1
DynStrStatus firstOccurrence(kmp_result* kmp_res, int* idx);

// (Run kmp_search before) Sets the indices ptr with the indices of all occurrences of the substr and count, else NULL and -1
DynStrStatus allOccurrences(kmp_result* kmp_res, size_t** indices, int* count);

#endif