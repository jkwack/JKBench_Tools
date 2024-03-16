#include <sycl/sycl.hpp>
#include <mpi.h>

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
	constexpr std::size_t N = 1024;
	auto *array = sycl::malloc_device<int>(N, Q);

	Q.submit([&](sycl::handler &h) {
			h.parallel_for<class MyKernelR_4>(sycl::nd_range<1>(N + dN, 1),
					[=](sycl::nd_item<1> item) {
					++array[item.get_global_id(0)];
					});
			});
	Q.wait();

	if (dN==0) printf("\t\t%40s%d\n","Finishing a noraml case at MPI rank: ",myid);
        else printf("\t\t%40s%d\n","Finishing an abnoraml case at MPI rank: ",myid);
	MPI_Finalize();

	return 0;
}

