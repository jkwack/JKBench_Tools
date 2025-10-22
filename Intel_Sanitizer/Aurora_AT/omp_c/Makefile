CC=icx

SRC_ASAN=test_asan_omp.c
EXE_ASAN=test_asan_omp
RUN_ASAN=run_asan_omp
SRC_MSAN=test_msan_omp.c
EXE_MSAN=test_msan_omp
RUN_MSAN=run_msan_omp
SRC_TSAN=test_tsan_omp.c
EXE_TSAN=test_tsan_omp
RUN_TSAN=run_tsan_omp


FLAGS_ASAN=-Xarch_device -fsanitize=address
FLAGS_MSAN=-Xarch_device -fsanitize=memory
FLAGS_TSAN=-Xarch_device -fsanitize=thread
FLAGS_OMP=-fiopenmp -fopenmp-targets=spir64 -g -O2
LDFLAGS=

EXES=$(EXE_ASAN) $(EXE_MSAN) $(EXE_TSAN)
RUNS=$(RUN_ASAN) $(RUN_MSAN) $(RUN_TSAN)

all: clean $(EXES) $(RUNS)

asan: $(EXE_ASAN) $(RUN_ASAN)

msan: $(EXE_MSAN) $(RUN_MSAN)

tsan: $(EXE_TSAN) $(RUN_TSAN)

$(EXE_ASAN): $(SRC_ASAN)
	rm -rf $@
	$(CC) $(FLAGS_OMP) $(FLAGS_ASAN) $^ -o $@ $(LDFLAGS)
	rm -rf *.o *.mod *.dSYM

$(RUN_ASAN): $(EXE_ASAN)
	echo -e "\n\nRunning $^:\n"
	unset ONEAPI_DEVICE_SELECTOR
	LIBOMPTARGET_PLUGIN=unified_runtime UR_ENABLE_LAYERS=UR_LAYER_ASAN ./$^

$(EXE_MSAN): $(SRC_MSAN)
	rm -rf $@
	$(CC) $(FLAGS_OMP) $(FLAGS_MSAN) $^ -o $@ $(LDFLAGS)
	rm -rf *.o *.mod *.dSYM

$(RUN_MSAN): $(EXE_MSAN)
	echo -e "\n\nRunning $^:\n"
	unset ONEAPI_DEVICE_SELECTOR
	LIBOMPTARGET_PLUGIN=unified_runtime UR_ENABLE_LAYERS=UR_LAYER_MSAN ./$^

$(EXE_TSAN): $(SRC_TSAN)
	$(CC) $(FLAGS_OMP) $(FLAGS_TSAN) $^ -o $@ $(LDFLAGS)
	rm -rf *.o *.mod *.dSYM

$(RUN_TSAN): $(EXE_TSAN)
	rm -rf $@
	echo -e "\n\nRunning $^:\n"
	unset ONEAPI_DEVICE_SELECTOR
	LIBOMPTARGET_PLUGIN=unified_runtime UR_ENABLE_LAYERS=UR_LAYER_TSAN ./$^




.IGNORE:
.SUFFIXES:
.SUFFIXES: .c .o .f90 .cu .cpp .cuf
.PHONY: clean $(EXES)
clean:
	rm -rf *.o *.mod $(EXES) *.dSYM



