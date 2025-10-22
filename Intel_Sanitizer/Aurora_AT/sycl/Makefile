CC=icpx

SRC_ASAN=test_asan.cpp
EXE_ASAN=test_asan
RUN_ASAN=run_asan
SRC_MSAN=test_msan.cpp
EXE_MSAN=test_msan
RUN_MSAN=run_msan
SRC_TSAN=test_tsan.cpp
EXE_TSAN=test_tsan
RUN_TSAN=run_tsan

FLAGS_ASAN=-Xarch_device -fsanitize=address
FLAGS_MSAN=-Xarch_device -fsanitize=memory
FLAGS_TSAN=-Xarch_device -fsanitize=thread
FLAGS_SYCL=-fsycl -g -O2
LDFLAGS=

EXES=$(EXE_ASAN) $(EXE_MSAN) $(EXE_TSAN)
RUNS=$(RUN_ASAN) $(RUN_MSAN) $(RUN_TSAN)

all: clean $(EXES) $(RUNS)

asan: $(EXE_ASAN) $(RUN_ASAN)

msan: $(EXE_MSAN) $(RUN_MSAN)

tsan: $(EXE_TSAN) $(RUN_TSAN)

$(EXE_ASAN): $(SRC_ASAN)
	rm -rf $@
	$(CC) $(FLAGS_SYCL) $(FLAGS_ASAN) $^ -o $@ $(LDFLAGS)
	rm -rf *.o *.mod *.dSYM

$(RUN_ASAN): $(EXE_ASAN)
	echo -e "\n\nRunning $^:\n"
	ONEAPI_DEVICE_SELECTOR=level_zero:gpu ./$^

$(EXE_MSAN): $(SRC_MSAN)
	rm -rf $@
	$(CC) $(FLAGS_SYCL) $(FLAGS_MSAN) $^ -o $@ $(LDFLAGS)
	rm -rf *.o *.mod *.dSYM

$(RUN_MSAN): $(EXE_MSAN)
	echo -e "\n\nRunning $^:\n"
	ONEAPI_DEVICE_SELECTOR=level_zero:gpu ./$^

$(EXE_TSAN): $(SRC_TSAN)
	rm -rf $@
	$(CC) $(FLAGS_SYCL) $(FLAGS_TSAN) $^ -o $@ $(LDFLAGS)
	rm -rf *.o *.mod *.dSYM

$(RUN_TSAN): $(EXE_TSAN)
	echo -e "\n\nRunning $^:\n"
	ONEAPI_DEVICE_SELECTOR=level_zero:gpu ./$^




.IGNORE:
.SUFFIXES:
.SUFFIXES: .c .o .f90 .cu .cpp .cuf
.PHONY: clean $(EXES)
clean:
	rm -rf *.o *.mod $(EXES) *.dSYM



