#include <sycl/sycl.hpp>
int main() {
	sycl::queue Q;
	constexpr std::size_t N = 1024;
	auto *array = sycl::malloc_device<int>(N, Q);

	Q.submit([&](sycl::handler &h) {
			h.parallel_for<class MyKernelR_4>(sycl::nd_range<1>(N + 1, 1),
					[=](sycl::nd_item<1> item) {
					++array[item.get_global_id(0)];
					});
			});
	Q.wait();
	return 0;
}

