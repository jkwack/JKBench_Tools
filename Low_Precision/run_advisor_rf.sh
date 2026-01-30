#!/bin/bash
#PBS -A Performance
#PBS -l select=1
#PBS -l walltime=6:00:00
#PBS -q prod
#PBS -l filesystems=home:flare
#PBS -j oe
#PBS -N Advisor_rf

cd $PBS_O_WORKDIR

ZE_AFFINITY_MASK=0.0 advisor --collect=roofline --profile-gpu --project-dir=Result_Advisor_RF.$PBS_JOBID -- ./gemm_mpicxx




