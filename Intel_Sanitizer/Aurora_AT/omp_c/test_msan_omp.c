#include <omp.h>

int main(void) {
  int device_id = omp_get_default_device();
  int *A = (int *)omp_target_alloc_device(8 * sizeof(int), device_id);

#pragma omp target parallel for is_device_ptr(A)
  for (size_t i = 0; i < 5; i++) {
    A[i] = A[i + 1] / A[i + 2];
  }

  omp_target_free(A, device_id);
  return 0;
}

