CC=mpicxx
cc=mpicc

SDIR=./
SRC_D01=${SDIR}/sycl_outofbound_usm.cpp
SRC_D02=${SDIR}/sycl_outofbound_slm.cpp
SRC_D03=${SDIR}/omp_outofbound_target_alloc.c

EXE_D01=sycl_outofbound_usm
EXE_D02=sycl_outofbound_slm
EXE_D03=omp_outofbound_target_alloc

EXES=$(EXE_D01) $(EXE_D02) $(EXE_D03)

CPPFLAGS=-fsycl -O2 -g
CFLAGS=-fiopenmp -fopenmp-targets=spir64 -O2 -g
FFLAGS=-O2 -g

ASAN_FLAGS=-fsanitize=address -Xarch_device
LDFLAGS=



all: $(EXES)

$(EXE_D01): $(SRC_D01)
	$(CC) $(CPPFLAGS) $^ -o $@ $(LDFLAGS)
	$(CC) $(CPPFLAGS) $(ASAN_FLAGS) -g $^ -o $@_ASAN $(LDFLAGS)
	rm -rf *.o *.mod *.dSYM

$(EXE_D02): $(SRC_D02)
	$(CC) $(CPPFLAGS) $^ -o $@ $(LDFLAGS)
	$(CC) $(CPPFLAGS) $(ASAN_FLAGS) -g $^ -o $@_ASAN $(LDFLAGS)
	rm -rf *.o *.mod *.dSYM

$(EXE_D03): $(SRC_D03)
	$(cc) $(CFLAGS) $^ -o $@ $(LDFLAGS)
	$(cc) $(CFLAGS) $(ASAN_FLAGS) -g $^ -o $@_ASAN $(LDFLAGS)
	rm -rf *.o *.mod *.dSYM


.SUFFIXE: .c .o .f90 .cu .cpp .cuf
.PHONY: clean
clean:
	rm -rf *.o *.mod *.dSYM $(EXES) *_ASAN


