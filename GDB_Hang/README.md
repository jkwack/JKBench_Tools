# JKBench_Tools/GDB_Hang

## How to build and run examples

### MPI cases

```
make 
mpirun -n <nMPI> gpu_tile_compact.sh ./Comp_GeoSeries_omp_mpicc_DP_DEBUG  <nColumn/row> <Order> <MPI rank for hang>
```

### Running 24 MPI ranks and rank 20 hangs
```
mpirun -n 24 gpu_tile_compact.sh ./Comp_GeoSeries_omp_mpicc_DP_DEBUG 1024 30 20
```



