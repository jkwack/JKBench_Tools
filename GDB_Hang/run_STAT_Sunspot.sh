#!/bin/bash
#PBS -A Performance
#PBS -l select=2
#PBS -l walltime=1:00:00
#PBS -q workq
#PBS -l filesystems=home
#PBS -j oe
#PBS -N STAT_case

cd $PBS_O_WORKDIR

source source_STAT_Sunspot
mpiexec -n 2 --ppn 1 ./helper_toggle_eu_debug.sh 1

## Build the app
make clean
make Comp_GeoSeries_omp_mpicc_DP_DEBUG

## MPI rank 14 hangs
mpiexec -n 24 --ppn 12 gpu_tile_compact.sh ./Comp_GeoSeries_omp_mpicc_DP_DEBUG 1024 30 14 &

sleep 30
time stat-cl --jobid $PBS_JOBID  -w -G -t 1  $(pidof mpiexec)




