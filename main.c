#include <stdio.h>
#include "dynarr/dynarr.h"

int main(void){
  DynArr arr = {0};
  int res;

  /* Check init() */
  printf("Running init()....\n");
  res = init(&arr, 4UL, 10UL);
  printf("  res: %d\n", res);

  printf("  elemsize: %d\n", arr.elem_size);
  printf("  capacity: %d\n", arr.capacity);
  printf("  count: %d\n", arr.count);
  printf("\n\n");

  /* Check extend() */
  /* Should not work plainly because it operates on count as it is designed to be an internal routine */
  printf("Running extend()....\n");
  res = extend(&arr, 10);
  printf("  res: %d\n", res);

  printf("  elemsize: %d\n", arr.elem_size);
  printf("  capacity: %d\n", arr.capacity);
  printf("  count: %d\n", arr.count);
  printf("\n\n");

  /* Check pushOne() */
  /* count must become 1 */
  int x = 5;
  printf("Running pushOne()....\n");
  res = pushOne(&arr, (void*)(&x));
  printf("  res: %d\n", res);

  printf("  elemsize: %d\n", arr.elem_size);
  printf("  capacity: %d\n", arr.capacity);
  printf("  count: %d\n", arr.count);
  printf("\n\n");

  /* Check pushOne(and extend, internally) on loop-over */
  /* count=11 and capacity=20 */
  printf("Running pushOne() under a loop....\n");
  for (int i=0; i<10; i++){
    pushOne(&arr, (void*)(&i));
  }

  printf("  elemsize: %d\n", arr.elem_size);
  printf("  capacity: %d\n", arr.capacity);
  printf("  count: %d\n", arr.count);
  printf("\n\n");

  /* Check pushMany(and extend, internally) */
  /* count=26 and capacity=40 */
  printf("Running pushMany()....\n");
  int sarr[15] = {100, 99, 98, 97, 96, 95, 94, 93, 92, 91, 90, 89, 88, 87, 86};
  res = pushMany(&arr, (void*)(&sarr), 15);
  printf("  res: %d\n", res);

  printf("  elemsize: %d\n", arr.elem_size);
  printf("  capacity: %d\n", arr.capacity);
  printf("  count: %d\n", arr.count);
  printf("\n\n");

  /* Check getelement (and boundcheck, internally) */
  /* All 26 elements printed properly */
  for (size_t i=0; i<arr.count; i++){
    printf("%d, ", *(int*)(getelement(&arr, i)));
  }
  printf("\n\n\n");

  /* Check getelement hoisted version */
  const int* p;
  p = getelement(&arr, 0);
  for (size_t i=0; i<arr.count; i++){
    printf("%d, ", *(p++));
  }
  printf("\n\n\n");

  /* Check setidx */
  const int* idx19 = getelement(&arr, 19);
  printf("idx19 before: %d\n", *idx19);
  int y = 55;
  printf("Running setidx()....\n");
  res = setidx(&arr, (void*)(&y), 19);
  printf("  res: %d\n", res);
  printf("  idx19 after: %d\n", *idx19);
  printf("\n\n");

  /* Check mergedyn2dyn */
  /* dest must print like arr */
  DynArr destArr = {0};
  printf("Running init() on destArr....\n");
  res = init(&destArr, 4UL, arr.count);
  printf("  res: %d\n", res);
  printf("Running mergedyn2dyn()....\n");
  res = mergedyn2dyn(&arr, &destArr);
  printf("  res: %d\n", res);

  for (size_t i=0; i<destArr.count; i++){
    printf("%d, ", *(int*)(getelement(&destArr, i)));
  }
  printf("\n\n\n");

  /* Check export2stack() */
  /* stackarr should print the same elements as arr */
  int stackarr[arr.count];
  printf("Running export2stack()....\n");
  res = export2stack(&arr, (void*)(&stackarr[0]));
  printf("  res: %d\n", res);

  for (int i=0; i<arr.count; i++){
    printf("%d, ", stackarr[i]);
  }
  printf("\n\n\n");

  /* Check insertidx() */
  /* count=27 */
  int pval = 78;
  printf("  count before: %d\n", arr.count);
  printf("Running insertidx()....\n");
  res = insertidx(&arr, (void*)(&pval), 14);
  printf("  res: %d\n", res);
  printf("  count after: %d\n", arr.count);

  for (size_t i=0; i<arr.count; i++){
    printf("%d, ", *(int*)(getelement(&arr, i)));
  }
  printf("\n\n\n");

  /* Check removeidx() */
  /* count=26 */
  printf("Running insertidx()....\n");
  printf("  count before: %d\n", arr.count);
  res = removeidx(&arr, 14);
  printf("  res: %d\n", res);
  printf("  count after: %d\n", arr.count);

  for (size_t i=0; i<arr.count; i++){
    printf("%d, ", *(int*)(getelement(&arr, i)));
  }
  printf("\n\n\n");
}
