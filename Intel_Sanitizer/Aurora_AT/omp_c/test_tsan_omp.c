#include <omp.h>

int main(void) {
  int device_id = omp_get_default_device();
  int *A = (int *)omp_target_alloc_device(sizeof(int), device_id);

#pragma omp target parallel for is_device_ptr(A)
  for (size_t i = 0; i < 16; i++) {
    *A += i;
  }

  omp_target_free(A, device_id);
  return 0;
}

