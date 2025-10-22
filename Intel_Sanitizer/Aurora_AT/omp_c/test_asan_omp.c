#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <omp.h>
#define length     64
int main(void)
{
  int device_id = omp_get_default_device();
  size_t bytes = length*sizeof(double);
  double * __restrict A = (double *) omp_target_alloc(bytes, device_id);
  if (A == NULL){
     printf(" ERROR: Cannot allocate space for A using omp_target_alloc().\n");
     exit(1);
  }
  #pragma omp target teams distribute parallel for is_device_ptr(A)
  for (size_t i=0; i<=length; i++) {     
      A[i] = 2.0;
  }
  omp_target_free(A, device_id);
  return 0;
}

