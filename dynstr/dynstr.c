#include "dynstr.h"

DynStrStatus init(DynString *str, size_t capacity){
  if (str->cap != 0) return -ALREADY_INIT;
  if (capacity == 0) return -INVALID_CAP;

  str->data = malloc(capacity);
  if (!str->data) return -MALLOC_FAILED;

  str->len = 0;
  str->cap = capacity;
  str->data[0] = '\0';

  return SUCCESS;
}

DynStrStatus extendCap(DynString *str, size_t add){
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

DynStrStatus populate(DynString *dest, const char *src){
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

size_t lenstr(const char *str){
  if (!str) return -INVALID_BUFF;

  size_t len = 0;
  while (*(str++) != '\0') len++;
  return len;
}

DynStrStatus boundcheck(size_t lb, size_t ub, size_t idx){ return (idx>= lb && idx < ub) ? SUCCESS : -INVALID_IDX; }

DynStrStatus getstr(const DynString *str, size_t idx, char **out){
  if (!str || !str->data) return -INVALID_DPTR;
  if (boundcheck(0, str->len, idx)) return -INVALID_IDX;

  *out = &str->data[idx];
  return SUCCESS;
}

DynStrStatus getslicedstr(const DynString *str, size_t start, size_t end, char *outstr){
  if (!str || !str->data) return -INVALID_DPTR;
  if (start >= str->len || end >= str->len) return -INVALID_RANGE;

  size_t slen = end-start;    // [start, end)
  memcpy(outstr, &str->data[start], slen);
  outstr[slen] = '\0';

  return SUCCESS;
}

DynStrStatus copystr(const char *src, char *dest){
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

DynStrStatus islcase(const char *str){
  if (!str) return -INVALID_BUFF;

  for (size_t i = 0; str[i] != '\0'; i++) {
    if (str[i] >= 'A' && str[i] <= 'Z')
      return -NOT_LCASE;
  }
  return SUCCESS;
}

DynStrStatus isucase(const char *str){
  if (!str) return -INVALID_BUFF;

  for (size_t i = 0; str[i] != '\0'; i++) {
    if (str[i] >= 'a' && str[i] <= 'z')
      return -NOT_UCASE;
  }
  return SUCCESS;
}

DynStrStatus tolcase(const char *str, char *lcase){
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

DynStrStatus toucase(const char *str, char *ucase){
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

DynStrStatus cmp2strs(const DynString *str1, const DynString *str2, int sensitivity){
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

size_t findchar(const char *str, char c, int sensitivity){
  if (!str) return -INVALID_BUFF;
  size_t count = 0;

  // case insensitive (1)
  if (sensitivity){
    for (int i = 0; str[i] != '\0'; i++){
      if (char2lcase(str[i]) == char2lcase(c))
        count++;
    }
  } 
  // case sensitive (0)
  else{
    for (int i = 0; str[i] != '\0'; i++)
      if (str[i] == c)
        count++;
  }

  if (!count) return -1;
  return count;
}

DynStrStatus exportdyntobuff(const DynString *str, char *buff){
  if (!str || !str->data) return -INVALID_DPTR;

  memcpy(buff, str->data, str->len);
  return SUCCESS;
}

DynStrStatus clearstr(DynString *str){
  if (!str || !str->data) return -INVALID_DPTR;

  str->len = 0;
  if (str->data) str->data[0] = '\0';
  return SUCCESS;
}

DynStrStatus freestr(DynString *str){
  if (!str || !str->data) return -INVALID_DPTR;

  free(str->data);
  str->cap = 0;
  str->len = 0;
  return SUCCESS;
}

/* Substring operations based on the KMP algorithm */

int kmp_build_lps(const char *pat, size_t plen, size_t *lps){
  if (!pat || plen == 0) return -1;

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

  return 0;
}

ssize_t kmp_search_one(const char *str, size_t slen, const char *pat, size_t plen){
  if (!str || !pat) return -1;
  if (plen==0 || slen==0 || plen > slen) return -1;

  size_t lps[plen];
  if (kmp_build_lps(pat, plen, lps) != 0) return -1;

  size_t i = 0;  // main str counter
  size_t k = 0;  // sub str  counter

  while (i+plen-k <= slen){
    if (str[i] == pat[k]){
      i++; k++;
      if (k == plen) return (ssize_t)(i-k);
    }
    else{
      if (k != 0) k = lps[k-1];
      else i++;
    }
  }

  return -1;
}

int kmp_search_all(const char *str, size_t slen, const char *pat, size_t plen, size_t *indices, size_t *occ_count){
  if (!str || !pat) return -1;
  if (plen==0 || slen==0 || plen > slen) return -1;

  size_t lps[plen];
  if (kmp_build_lps(pat, plen, lps) != 0) return -1;

  size_t i = 0;       // main str counter
  size_t k = 0;       // sub str  counter
  size_t count = 0;   // for indices

  while (i < slen){
    if (str[i] == pat[k]){
      i++; k++;
      if (k == plen){
        indices[count++] = (i-k);
        k = lps[plen-1];
      }
    }
    else{
      if (k != 0) k = lps[k-1];
      else i++;
    }
  }

  if (!count) return -1;
  *occ_count = count;
  return 0;
}

DynStrStatus isin(const DynString *str, const char *substr, int sensitivity){
  if (!str || !str->data) return -INVALID_DPTR;
  if (!substr) return -INVALID_BUFF;

  size_t sublen = lenstr(substr);

  // sensitivity == 1 :: case insensitive
  if (sensitivity){
    char tmp_str[str->len+1], tmp_substr[sublen+1];
    tolcase(str->data, tmp_str);
    tolcase(substr, tmp_substr);
    return (kmp_search_one(tmp_str, str->len, tmp_substr, sublen) != -1) ? SUCCESS : SUBSTR_NOT_FOUND;
  }

  // sensitivity == 0 :: case sensitive
  return (kmp_search_one(str->data, str->len, substr, sublen) != -1) ? SUCCESS : SUBSTR_NOT_FOUND;
}

ssize_t firstOccurrence(const DynString *str, const char *substr, int sensitivity){
  if (!str || !str->data) return -INVALID_DPTR;
  if (!substr) return -INVALID_BUFF;

  size_t sublen = lenstr(substr);

  // case insensitive (1)
  if (sensitivity){
    char tmp_str[str->len+1], tmp_substr[sublen+1];
    tolcase(str->data, tmp_str);
    tolcase(substr, tmp_substr);

    return kmp_search_one(tmp_str, str->len, tmp_substr, sublen);
  }

  // case sensitive (0)
  return kmp_search_one(str->data, str->len, substr, sublen);
}

DynStrStatus allOccurrences(const DynString *str, const char *substr, size_t *indices, size_t *occ_count, int sensitivity){
  if (!str || !str->data) return -INVALID_DPTR;
  if (!substr) return -INVALID_BUFF;

  size_t sublen = lenstr(substr);

  // case insensitive (1)
  if (sensitivity){
    char tmp_str[str->len+1], tmp_substr[sublen+1];
    tolcase(str->data, tmp_str);
    tolcase(substr, tmp_substr);

    return kmp_search_all(tmp_str, str->len, tmp_substr, sublen, indices, occ_count) == 0 ? SUCCESS : SUBSTR_NOT_FOUND;
  }

  // case sensitive (0)
  return kmp_search_all(str->data, str->len, substr, sublen, indices, occ_count) == 0 ? SUCCESS : SUBSTR_NOT_FOUND;
}
