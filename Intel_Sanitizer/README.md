# JKBench_Tools/Intel_Sanitizer

## How to build and run examples

### MPI cases

```
make omp_outofbound_target_alloc 
mpirun -n 12 ./omp_outofbound_target_alloc

make sycl_outofbound_usm 
mpirun -n 12 ./sycl_outofbound_usm 

make sycl_outofbound_slm 
mpirun -n 12 ./sycl_outofbound_slm 
```

### No MPI cases

```
cd NoMPI

make omp_outofbound_target_alloc
./omp_outofbound_target_alloc

make sycl_outofbound_usm
./sycl_outofbound_usm

make sycl_outofbound_slm
./sycl_outofbound_slm
```
