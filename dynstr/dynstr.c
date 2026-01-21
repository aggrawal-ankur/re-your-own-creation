#include "dynstr.h"

DynStrStatus init(DynString* str, size_t capacity){
  if (str->cap != 0) return -ALREADY_INIT;
  if (capacity == 0) return -INVALID_CAP;

  str->data = malloc(capacity);
  if (!str->data) return -MALLOC_FAILED;

  str->len = 0;
  str->cap = capacity;
  str->data[0] = '\0';

  return SUCCESS;
}

DynStrStatus extendCap(DynString* str, size_t add){
  if (!str || !str->data) return -INVALID_DPTR;
  if (str->cap >= add)  return  SUCCESS;

  size_t ncap = str->cap;
  while (ncap < add+1) ncap *= 2;

  void *tmp = realloc(str->data, ncap);
  if (!tmp) return -REALLOC_FAILED;

  str->data = tmp;
  str->cap = ncap;
  return SUCCESS;
}

DynStrStatus populate(DynString* dest, const char* src){
  if (!dest || !dest->data) return -INVALID_DPTR;
  if (!src) return -INVALID_BUFF;

  size_t nlen = dest->len + lenstr(src);

  int res = extendCap(dest, nlen+1);
  if (res != SUCCESS) return res;

  memcpy(dest->data+dest->len, src, lenstr(src));
  dest->len = nlen;
  dest->data[nlen] = '\0';

  return SUCCESS;
}

size_t lenstr(const char* str){
  if (!str) return -INVALID_BUFF;

  size_t len = 0;
  while (*(str++) != '\0') len++;
  return len;
}

DynStrStatus boundcheck(size_t lb, size_t ub, size_t idx){ return (idx>= lb && idx < ub) ? SUCCESS : -INVALID_IDX; }

DynStrStatus getstr(const DynString* str, size_t idx, char** out){
  if (!str || !str->data) return -INVALID_DPTR;
  if (boundcheck(0, str->len, idx)) return -INVALID_IDX;

  *out = &str->data[idx];
  return SUCCESS;
}

DynStrStatus getslicedstr(const DynString* str, size_t start, size_t end, char* outstr){
  if (!str || !str->data) return -INVALID_DPTR;
  if (start >= str->len || end >= str->len) return -INVALID_RANGE;

  size_t slen = end-start;    // [start, end)
  memcpy(outstr, &str->data[start], slen);
  outstr[slen] = '\0';

  return SUCCESS;
}

DynStrStatus copystr(const char* src, char* dest){
  if (!src) return -INVALID_BUFF;

  int len = lenstr(src);
  memcpy(dest, src, len);
  dest[len] = '\0';
  return SUCCESS;
}

char char2lcase(char c){
  if (c >= 'A' && c <= 'Z') return c | 0x20;
  return c;
}

char char2ucase(char c){
  if (c >= 'a' && c <= 'z') return c & ~0x20;
  return c;
}

DynStrStatus islcase(const char* str){
  if (!str) return -INVALID_BUFF;

  for (size_t i = 0; str[i] != '\0'; i++) {
    if (str[i] >= 'A' && str[i] <= 'Z')
      return -NOT_LCASE;
  }
  return SUCCESS;
}

DynStrStatus isucase(const char* str){
  if (!str) return -INVALID_BUFF;

  for (size_t i = 0; str[i] != '\0'; i++) {
    if (str[i] >= 'a' && str[i] <= 'z')
      return -NOT_UCASE;
  }
  return SUCCESS;
}

DynStrStatus tolcase(const char* str, char* lcase){
  if (!str) return -INVALID_BUFF;

  int res = copystr(str, lcase);
  if (res != SUCCESS) return res;

  int i = 0;
  while (lcase[i] != '\0'){
    lcase[i] = char2lcase(lcase[i]);
    i++;
  }
  lcase[i] = '\0';

  if (islcase(lcase) == SUCCESS) return SUCCESS;
  return -TOLCASE_FAILED;
}

DynStrStatus toucase(const char* str, char* ucase){
  if (!str) return -INVALID_BUFF;

  int res = copystr(str, ucase);
  if (res != SUCCESS) return res;

  int i = 0;
  while (ucase[i] != '\0'){
    ucase[i] = char2ucase(ucase[i]);
    i++;
  }
  ucase[i] = '\0';

  if (isucase(ucase) == SUCCESS) return SUCCESS;
  return -TOUCASE_FAILED;
}

DynStrStatus cmp2strs(const DynString* str1, const DynString* str2, int sensitivity){
  if (!str1 || !str1->data || !str2->data || !str2) return -INVALID_DPTR;
  if (str1->len != str2->len) return -STRS_NOT_EQUAL;

  // sensitivity: 0 (sensitive) 1 (insensitive)
  if (sensitivity == 0){
    int res = memcmp(str1->data, str2->data, str1->len);
    if (res == 0) return SUCCESS;
    return -STRS_NOT_EQUAL;
  }

  char tmp1[str1->len+1], tmp2[str2->len+1];
  if (tolcase(str1->data, tmp1) != SUCCESS) return -CMP_FAILED;
  if (tolcase(str2->data, tmp2) != SUCCESS) return -CMP_FAILED;

  if (memcmp(tmp1, tmp2, str1->len) == 0) return SUCCESS;
  return -STRS_NOT_EQUAL;
}

DynStrStatus findchar(const char* str, char c, int sensitivity, int* count){
  if (!str) return -INVALID_BUFF;
  int occ = 0;

  // case insensitive (1)
  if (sensitivity){
    for (int i = 0; str[i] != '\0'; i++){
      if (char2lcase(str[i]) == char2lcase(c))
        occ++;
    }
  }
  // case sensitive (0)
  else{
    for (int i = 0; str[i] != '\0'; i++)
      if (str[i] == c)
        occ++;
  }

  if (!occ) return CHAR_NOT_FOUND;

  *count = occ;
  return SUCCESS;
}

DynStrStatus exportdyntobuff(const DynString* str, char* buff){
  if (!str || !str->data) return -INVALID_DPTR;

  memcpy(buff, str->data, str->len);
  return SUCCESS;
}

DynStrStatus clearStr(DynString* str){
  if (!str || !str->data) return -INVALID_DPTR;

  str->len = 0;
  if (str->data) str->data[0] = '\0';
  return SUCCESS;
}

DynStrStatus freeStr(DynString* str){
  if (!str || !str->data) return -INVALID_DPTR;

  free(str->data);
  str->cap = 0;
  str->len = 0;
  return SUCCESS;
}

/* Substring operations based on the KMP algorithm */

static inline DynStrStatus kmp_build_lps(const char* pat, size_t plen, size_t *lps){
  if (!pat || plen == 0) return -INVALID_BUFF;

  size_t len = 0;
  lps[0] = 0;

  for (size_t i = 1; i < plen;){
    if (pat[i] == pat[len]){
      len++;
      lps[i] = len;
      i++;
    } else if (len != 0){
      len = lps[len-1];
    } else{
      lps[i] = 0;
      i++;
    }
  }

  return SUCCESS;
}

DynStrStatus kmp_search(const char* str, const char* pat, kmp_result* kmp_obj){
  if (!str || !pat) return -INVALID_BUFF;

  size_t slen = lenstr(str);
  size_t plen = lenstr(pat);
  if (plen==0 || slen==0 || plen > slen) return -INVALID_BUFF;

  size_t lps[plen];
  int res = kmp_build_lps(pat, plen, lps);
  if (res != SUCCESS) return res;

  size_t i = 0;       // main str counter
  size_t k = 0;       // sub str  counter
  size_t count = 0;   // for indices

  while (i < slen){
    if (str[i] == pat[k]){
      i++; k++;
      if (k == plen){
        kmp_obj->indices[count] = (i-k);
        count++;
        k = lps[plen-1];
      }
    }
    else{
      if (k != 0) k = lps[k-1];
      else i++;
    }
  }

  if (!count){
    kmp_obj->indices = NULL;
    kmp_obj->count = 0;
    return -SUBSTR_NOT_FOUND;
  }

  kmp_obj->count = count;
  return SUCCESS;
}

DynStrStatus isin(kmp_result* kmp_res){
  if (!kmp_res) return -KMP_RES_INVALID;
  if (kmp_res->count == 0) return -SUBSTR_NOT_FOUND;

  return SUCCESS;
}

DynStrStatus firstOccurrence(kmp_result* kmp_res, int* idx){
  if (!kmp_res) return -KMP_RES_INVALID;
  if (kmp_res->count == 0 || kmp_res->indices == NULL){
    *idx = -1;
    return -SUBSTR_NOT_FOUND;
  }

  *idx = kmp_res->indices[0];
  return SUCCESS;
}

DynStrStatus allOccurrences(kmp_result* kmp_res, size_t** indices, int* count){
  if (!kmp_res) return -KMP_RES_INVALID;
  if (kmp_res->count == 0 || kmp_res->indices == NULL){
    *count = -1;
    *indices = NULL;
    return -SUBSTR_NOT_FOUND;
  }

  *indices = kmp_res->indices;
  *count = kmp_res->count;
  return SUCCESS;
}
