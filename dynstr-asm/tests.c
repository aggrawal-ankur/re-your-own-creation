#include <stdio.h>
#include "../dynstr/dynstr.h"

int main(void){
  DynString str1 = {0};
  int res;
  printf("Running init()....\n");
  res = init(&str1, 10);
  printf("  res: %d\n", res);
  printf("  len: %d\n", str1.len);
  printf("  cap: %d\n", str1.cap);
  printf("\n\n");

  printf("Running populate(also checks lenstr and extendCap)....\n");
  res = populate(&str1, "My Name Is Anna!\n");
  printf("  res: %d\n", res);
  printf("  len: %d\n", str1.len);
  printf("  cap: %d\n", str1.cap);
  printf("  ptr:%s", str1.data);
  printf("\n\n");

  printf("Running getstr(also checks boundcheck internally)....\n");
  char *buff;
  res = getstr(&str1, 5, &buff);
  printf("  res: %d\n", res);
  printf("string thru a pointer returned by getstr: %s", buff);
  printf("\n\n");

  printf("Running getslicedstr()....\n");
  char buff2[100];
  res = getslicedstr(&str1, 5, 12, &buff2[0]);
  printf("  res: %d\n", res);
  printf("string thru a pointer returned by getslicedstr: %s", buff2);
  printf("\n\n");

  printf("Running islcase()....\n");
  res = islcase(str1.data);
  printf("  res: %d\n", res);
  printf("\n\n");

  printf("Running tolcase(also copystr internally)....\n");
  char lcase[100];
  res = tolcase(str1.data, lcase);
  printf("  res (tolcase): %d\n", res);
  res = islcase(lcase);
  printf("  res (islcase): %d\n", res);
  printf("Org: %s", str1.data);
  printf("lcase: %s", lcase);
  printf("\n\n");

  printf("Running isucase()....\n");
  res = isucase(str1.data);
  printf("  res: %d\n", res);
  printf("\n\n");

  printf("Running toucase(also copystr internally)....\n");
  char ucase[100];
  res = toucase(str1.data, ucase);
  printf("  res (toucase): %d\n", res);
  res = isucase(ucase);
  printf("  res (isucase): %d\n", res);
  printf("Org: %s", str1.data);
  printf("ucase: %s", ucase);
  printf("\n\n");

  printf("Running cmp2strs() in sensitive mode....\n");
  DynString str2 = {0};
  init(&str2, 50);
  populate(&str2, "My name iS anna!\n");
  printf("  ptr1: %s", str1.data);
  printf("  ptr2: %s", str2.data);
  res = cmp2strs(&str1, &str2, 0);
  printf("  res: %d\n", res);
  printf("\n\n");

  printf("Running cmp2strs() in insensitive mode....\n");
  DynString str3 = {0};
  init(&str3, 50);
  populate(&str3, "My name iS anna!\n");
  printf("  ptr1: %s", str1.data);
  printf("  ptr3: %s", str3.data);
  res = cmp2strs(&str1, &str3, 1);
  printf("  res: %d\n", res);
  printf("\n\n");

  printf("Running findchar(sensitive)....\n");
  int count;
  count=-1;
  res = findchar(str1.data, 'm', 0, &count);
  printf("  res: %d\n", res);
  printf("  total occurrence of 'm' in sensitive mode: %d\n", count);
  count=-1;
  printf("Running findchar(insensitive)....\n");
  res = findchar(str1.data, 'm', 1, &count);
  printf("  res: %d\n", res);
  printf("  total occurrence of 'm' in insensitive mode: %d\n", count);
  printf("\n\n");

  kmp_result kmp_obj;
  kmp_obj.indices = malloc(100);
  printf("Running kmp_search()...\n");
  DynString str4 = {0};
  init(&str4, 50);
  populate(&str4, "My name iS anna!\n");
  populate(&str4, " My name iS anna!\n");
  populate(&str4, " My name iS anna!\n");
  populate(&str4, " My name iS anna!\n");
  res = kmp_search(str4.data, "My", &kmp_obj);
  printf("  res: %d\n", res);
  printf("\n\n");

  printf("isin: %d\n", isin(&kmp_obj));
  printf("\n\n");

  int idx;
  printf("firstOccurrence: %d\n", firstOccurrence(&kmp_obj, &idx));
  printf("  idx: %d", idx);
  printf("\n\n");

  size_t* indices;
  count = 0;
  printf("allOccurrences: %d\n", allOccurrences(&kmp_obj, &indices, &count));
  printf("  count: %d", count);
  printf("\n\n");
}
