#!/bin/bash

export FI_CXI_DEFAULT_CQ_SIZE=131072
export FI_CXI_CQ_FILL_PERCENT=20

NNODES=`wc -l < $PBS_NODEFILE`
NMPI=$(( NNODES * 12 ))

EXE=/home/jkwack/Apps/kynema-sgf/JK_build_oneapi2025.3.1_20260522/kynema_sgf
INPUT=/home/jkwack/Apps/kynema-sgf/JK_build_oneapi2025.3.1_20260522/inputs/abl_godunov_N0001_15min_v4.inp
MAX_STEP=1

mpiexec -n $NMPI --ppn 12 gpu_tile_compact.sh ${EXE} ${INPUT} time.max_step=${MAX_STEP}

