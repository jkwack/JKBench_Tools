#include "sycl/sycl.hpp"

int main() {
  sycl::queue Q;
  auto *array = sycl::malloc_device<char>(1, Q);

  Q.submit([&](sycl::handler &h) {
     h.parallel_for<class Test>(
         sycl::nd_range<1>(32, 8),
         [=](sycl::nd_item<1> it) { *array += it.get_global_linear_id(); });
   }).wait();

  sycl::free(array, Q);
  return 0;
}
