# JKBench_Tools/Read_smi

## Instruction to collect power data

### NVIDIA-SMI on Polaris
```
export timetag=$(date | awk '{print $4 "-" $3 "-" $2 "-" $5}'| awk -F: '{print $1 "-" $2 "-" $3}')
export OUTPUT=OUT_${timetag}.txt
export POUTPUT=POUT_nvidia-smi_${timetag}.csv
nvidia-smi --query-gpu=timestamp,pci.bus,utilization.gpu,power.draw,clocks.gr --format=csv -l 1 -i 3 >> $POUTPUT &

mpiexec -n 1 --ppn 4 ./set_affinity_gpu_polaris.sh ./a.out &> $OUTPUT

kill -9 `pgrep -f nvidia-smi`
```

### Intel XPU-SMI on Aurora or Sunspot

```
export timetag=$(date | awk '{print $4 "-" $3 "-" $2 "-" $5 "-" $6}' | awk -F: '{print $1 "-" $2 "-" $3}')
export OUTPUT=OUT_${timetag}.txt
export POUTPUT=POUT_xpu-smi_${timetag}.csv

xpu-smi dump -d 0 -m 0,1,2,8 >> $POUTPUT &

mpiexec -n 2 gpu_tile_compact.sh  ./a.out &> $OUTPUT

kill -9 `pgrep -f xpu-smi`

```

### AMD ROCM-SMI (WIP)

```
export timetag=$(date | awk '{print $4 "-" $3 "-" $2 "-" $5 "-" $6}' | awk -F: '{print $1 "-" $2 "-" $3}')
export OUTPUT=OUT_${timetag}.txt
export POUTPUT=POUT_rocm-smi_${timetag}.csv

watch -n 1 "date >> $POUTPUT && rocm-smi -d 0 -P -u -g --showenergycounter --csv >> $POUTPUT " &

srun -n 2 ./a.out &> $OUTPUT

kill -9 `pgrep -f watch`
```

## Intruction to post-process the collected power data

```
./Read_smi -i PUT_nvidia-smi.csv           # for NVIDIA GPUs
./Read_smi -i PUT_xpu-smi.csv              # for Intel GPUs
./Read_smi -i PUT_rocm-smi.csv             # for AMD GPUs
```
