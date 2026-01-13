#ifndef DYNSTR_CORE_H
#define DYNSTR_CORE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

// Return codes
typedef enum {
  SUCCESS = 0,
  EMPTY_STR = -1,
  MALLOC_FAILED = -2,
  REALLOC_FAILED = -3,
  INVALID_IDX = -4,
  NOT_LCASE = -6,
  NOT_UCASE = -7,
  TOLCASE_FAILED = -8,
  TOUCASE_FAILED = -9,
  STRS_NOT_EQUAL = -10,
  SUBSTR_NOT_FOUND = -11,
  EXT_NOT_REQUIRED = -12,
  USE_CONCAT = -13,
  EMPTY_SRC = -14,
} DynStrStatus;

// Dynamic string struct
typedef struct {
  char *data;
  size_t len;   // doesn't include \0
  size_t cap;   // including \0
} DynString;

/* Utilitiess */

// Initialize the dynamic string
DynStrStatus init(DynString *str, size_t capacity);

// Calculates the length of a string :: callee must ensure str validation
size_t lenstr(const char *str);

// Populate a new dynamic string with a char buff
DynStrStatus populate(DynString *dest, const char *src);

// Concatenate a char buff into an existing dynamic string
#define concatbuff populate

// Concatenate two dynamic strings in dest
DynStrStatus concat2d(DynString *dest, const DynString *src);

// Verify an idx against a set of bounds
int boundcheck(size_t lb, size_t ub, size_t idx);

// Returns a pointer to the dynamic string
DynStrStatus getstr(const DynString *str, size_t idx, char **out);

// Slice a dynamic string and return a pointer to the first character
DynStrStatus getslicedstr(const DynString *str, size_t start, size_t end, DynString *outstr);

// Compare two dynamic strings
DynStrStatus cmp2strs(const DynString *str1, const DynString *str2, int sensitivity);

// Clear and mark a dynamic string to be reused again.
DynStrStatus clearstr(DynString *str);

// Deallocate the dynamic string completely
DynStrStatus freestr(DynString *str);

// Export a dynamic string to a char buffer
DynStrStatus exportdyntobuff(const DynString *str, char *buff);

// Convert a string to lowercase
DynStrStatus tolcase(const char *str, char *lcase);

// Convert a string to uppercase
DynStrStatus toucase(const char *str, char *ucase);

// Check if a string is lowercase
DynStrStatus islcase(const char *str);

// Check if a string is uppercase
DynStrStatus isucase(const char *str);

// Checks the presence of a substring in a string
DynStrStatus isin(const DynString *str, const char *substr, int sensitivity);

// Returns the first occurrence of a substr, else -1
ssize_t firstOccurrence(const DynString *str, const char *substr, int sensitivity);

// Populates the indices array with the indices of all occurrences of a substr, else -1
DynStrStatus allOccurrences(const DynString *str, const char *substr, size_t *indices, size_t *occ_count, int sensitivity);

// Returns the number of occurrences of a character
size_t findchar(const char *str, char c, int sensitivity);

#endif