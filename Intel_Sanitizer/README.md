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

### Aurora AT cases

```
cd Aurora_AT

cd sycl
make all

cd ../omp_c
make all

cd ../omp_fortran
make all

```
The followings are expected:
```
jkwack@x4604c5s2b0n0:/flare/Performance/jkwack/HPC_benchmarks/JKBench_Tools/Intel_Sanitizer/Aurora_AT/sycl> make all
rm -rf *.o *.mod test_asan test_msan test_tsan *.dSYM
rm -rf test_asan
icpx -fsycl -g -O2 -Xarch_device -fsanitize=address test_asan.cpp -o test_asan 
rm -rf *.o *.mod *.dSYM
rm -rf test_msan
icpx -fsycl -g -O2 -Xarch_device -fsanitize=memory test_msan.cpp -o test_msan 
rm -rf *.o *.mod *.dSYM
rm -rf test_tsan
icpx -fsycl -g -O2 -Xarch_device -fsanitize=thread test_tsan.cpp -o test_tsan 
rm -rf *.o *.mod *.dSYM
echo -e "\n\nRunning test_asan:\n"


Running test_asan:

ONEAPI_DEVICE_SELECTOR=level_zero:gpu ./test_asan
==== DeviceSanitizer: ASAN

====ERROR: DeviceSanitizer: out-of-bounds-access on Device USM (0xff00fffffffd1100)
READ of size 4 at kernel <typeinfo name for main::'lambda'(sycl::_V1::handler&)::operator()(sycl::_V1::handler&) const::MyKernel> LID(0, 0, 0) GID(1023, 0, 0)
  #0 typeinfo name for main::'lambda'(sycl::_V1::handler&)::operator()(sycl::_V1::handler&) const::MyKernel /flare/Performance/jkwack/HPC_benchmarks/JKBench_Tools/Intel_Sanitizer/Aurora_AT/sycl/test_asan.cpp:9
make: [Makefile:37: run_asan] Error 1 (ignored)
echo -e "\n\nRunning test_msan:\n"


Running test_msan:

ONEAPI_DEVICE_SELECTOR=level_zero:gpu ./test_msan
==== DeviceSanitizer: MSAN
====WARNING: DeviceSanitizer: use-of-uninitialized-value)
use of size 1 at kernel <typeinfo name for main::'lambda'(sycl::_V1::handler&)::operator()(sycl::_V1::handler&) const::MyKernel> LID(0, 0, 0) GID(0, 0, 0)
  #0 typeinfo name for main::'lambda'(sycl::_V1::handler&)::operator()(sycl::_V1::handler&) const::MyKernel /flare/Performance/jkwack/HPC_benchmarks/JKBench_Tools/Intel_Sanitizer/Aurora_AT/sycl/test_msan.cpp:13
make: [Makefile:46: run_msan] Error 1 (ignored)
echo -e "\n\nRunning test_tsan:\n"


Running test_tsan:

ONEAPI_DEVICE_SELECTOR=level_zero:gpu ./test_tsan
==== DeviceSanitizer: TSAN
====WARNING: DeviceSanitizer: data race
When write of size 1 at 0xff00fffffffe0000 in kernel <typeinfo name for main::'lambda'(sycl::_V1::handler&)::operator()(sycl::_V1::handler&) const::Test> LID(7, 0, 0) GID(23, 0, 0)
  #0 typeinfo name for main::'lambda'(sycl::_V1::handler&)::operator()(sycl::_V1::handler&) const::Test /flare/Performance/jkwack/HPC_benchmarks/JKBench_Tools/Intel_Sanitizer/Aurora_AT/sycl/test_tsan.cpp:10

```

