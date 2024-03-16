# JKBench_Tools/Intel_Sanitizer

## How to build and run examples

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


