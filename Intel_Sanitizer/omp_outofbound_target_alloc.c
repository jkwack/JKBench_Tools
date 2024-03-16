#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <omp.h>
#include <mpi.h>
#define length 1024
int main (int argc, char **argv)
{
	// For MPI
	int myid=0, numprocs=1;
	MPI_Init( &argc, &argv);
	MPI_Comm_rank (MPI_COMM_WORLD, &myid);
	MPI_Comm_size (MPI_COMM_WORLD, &numprocs);
   	if (myid == 0) {
      		printf("\t%20s%d\n\n","Number of MPI process: ",numprocs);
   	}
	MPI_Barrier(MPI_COMM_WORLD);
	int dL=myid%2;

	int device_id = omp_get_default_device();
	size_t bytes = length*sizeof(double);
	double *__restrict A = (double *) omp_target_alloc(bytes, device_id);
	if (A==NULL) {
		printf("ERROR: Cannot allocate space for A using omp_target_alloc().\n");
		exit(1);
	}

#pragma omp target teams distribute parallel for is_device_ptr(A)
	for (size_t i=0; i<length+dL; i++) {
		A[i] = 2.0;
	}
	if (dL==0) printf("\t\t%40s%d\n","Finishing a noraml case at MPI rank: ",myid);
	else printf("\t\t%40s%d\n","Finishing an abnoraml case at MPI rank: ",myid);
	
	omp_target_free(A, device_id);
	MPI_Finalize();
	return 0;
}

