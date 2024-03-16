#include <sycl/sycl.hpp>
#include <mpi.h>

constexpr std::size_t N = 16;
constexpr std::size_t group_size = 8;

int main(int argc, char **argv) {
        // For MPI
        int myid=0, numprocs=1;
        MPI_Init( &argc, &argv);
        MPI_Comm_rank (MPI_COMM_WORLD, &myid);
        MPI_Comm_size (MPI_COMM_WORLD, &numprocs);
        if (myid == 0) {
                printf("\t%20s%d\n\n","Number of MPI process: ",numprocs);
        }
        MPI_Barrier(MPI_COMM_WORLD);
        int dN=myid%2;

	sycl::queue Q;
	auto *data = sycl::malloc_host<int>(1, Q);

	Q.submit([&](sycl::handler &h) {
			h.parallel_for<class MyKernel>(
					sycl::nd_range<1>(N, group_size), [=](sycl::nd_item<1> item) {
					auto &ref = *sycl::ext::oneapi::group_local_memory<int[N]>(
							item.get_group());
					ref[item.get_local_linear_id() * 2*dN + 4*dN] = 42;
					});
			});

	Q.wait();

	if (dN==0) printf("\t\t%40s%d\n","Finishing a noraml case at MPI rank: ",myid);
        else printf("\t\t%40s%d\n","Finishing an abnoraml case at MPI rank: ",myid);
        MPI_Finalize();
	return 0;
}
