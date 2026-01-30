#CC=icx
CC=mpicxx

SDIR=./
SRC=${SDIR}/gemm.cpp

EXE=gemm_${CC}
EXE_DEBUG=gemm_${CC}_DEBUG
CPPFLAGS_PROFILE=-O2 -fdebug-info-for-profiling -gline-tables-only
CPPFLAGS_DEBUG=-g -O0
CPPFLAGS_COMMON=-fsycl
LDFLAGS= -qmkl

EXES=$(EXE) $(EXE_DEBUG) 

all: $(EXES)

$(EXE): $(SRC)
	$(CC) $(CPPFLAGS_COMMON) $(CPPFLAGS_PROFILE) $^ -o $@ $(LDFLAGS)
	rm -rf *.o *.mod *.dSYM

$(EXE_DEBUG): $(SRC)
	$(CC) $(CPPFLAGS_COMMON) $(CPPFLAGS_DEBUG)  $^ -o $@ $(LDFLAGS)
	rm -rf *.o *.mod *.dSYM



.SUFFIXES:
.SUFFIXES: .c .o .f90 .cu .cpp .cuf
.PHONY: clean
clean:
	rm -rf *.o *.mod $(EXES) *.dSYM


