#include <sycl/sycl.hpp>

__attribute__((noinline)) int foo(int data1, int data2) {
  return data1 + data2;
}

int main() {
  sycl::queue Q;
  auto *array = sycl::malloc_device<int>(2, Q);

  Q.submit([&](sycl::handler &h) {
    h.single_task<class MyKernel>(
        [=]() { array[0] = foo(array[0], array[1]); });
  });
  Q.wait();

  sycl::free(array, Q);
  return 0;
}

