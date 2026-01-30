#!/bin/bash
#PBS -A Performance
#PBS -l select=1
#PBS -l walltime=1:00:00
#PBS -q prod
#PBS -l filesystems=home:flare
#PBS -j oe
#PBS -N Vtune_inst

cd $PBS_O_WORKDIR

ZE_AFFINITY_MASK=0.0 vtune -collect gpu-hotspots -knob characterization-mode=instruction-count  -r Result_VTune_inst.$PBS_JOBID -- ./gemm_mpicxx




