#!/bin/bash
#PBS -A Performance
#PBS -l select=1
#PBS -l walltime=9:00:00
#PBS -q workq
#PBS -l filesystems=home:tegu
#PBS -j oe
#PBS -N Power_Measurement

cd $PBS_O_WORKDIR
module li

NNODES=`wc -l < $PBS_NODEFILE`
NMPI=$(( NNODES * 12 ))

jobid=$(echo $PBS_JOBID | awk -F . '{print $1}')
OUTDIR=output.${jobid}
mkdir -p ${OUTDIR}
OUT_POWER=${OUTDIR}/output_power.${jobid}.txt

# Seed per-run metadata: copy template, fill in run_id and date.
# Colleagues should open ${METADATA} after the run and fill the rest.
METADATA=${OUTDIR}/metadata.${jobid}.yaml
if [ -f run-metadata.yaml ]; then
	cp run-metadata.yaml ${METADATA}
	sed -i \
		-e "s|^run_id:.*|run_id: ${jobid}|" \
		-e "s|^date:.*|date: $(date -Idate)|" \
		${METADATA}
else
	echo "WARNING: run-metadata.yaml template not found; skipping ${METADATA}" >&2
fi

declare -a GPU_FREQ
declare -a GPU_EnergyStart
declare -a GPU_EnergyEnd

GPU_EnergyStart_all=0
GPU_EnergyEnd_all=0

FREQ_MAX=1600
FREQ_MIN=800
FREQ_STEP=100

for FREQ in $(seq $FREQ_MAX -$FREQ_STEP $FREQ_MIN)
do
	# Updating GPU Frequency
	echo " " &>> ${OUT_POWER}
	echo "Start running in ${FREQ} MHz " &>> ${OUT_POWER}
	mpirun -n $NNODES --ppn 1 ./freq_set.sh $FREQ
	sleep 1

	# Measuring Energy
	EnergyStart=$(geopmread MSR::BOARD_ENERGY board 0)
	for chip in $(seq 0 11)
        do
                GPU_EnergyStart[${chip}]=$(geopmread GPU_CHIP_ENERGY gpu_chip $chip )
        done
	TStart=$(date +%s.%N)
	./Run_my_app.sh &>> ${OUTDIR}/output_app.FREQ${FREQ}.${jobid}.txt
	APP_RC=$?
	TEnd=$(date +%s.%N)
	RUNTIME=$(awk -v s="$TStart" -v e="$TEnd" 'BEGIN { printf "%.3f", e - s }')
	EnergyEnd=$(geopmread MSR::BOARD_ENERGY board 0)
	for chip in $(seq 0 11)
        do
                GPU_EnergyEnd[${chip}]=$(geopmread GPU_CHIP_ENERGY gpu_chip $chip )
        done
	for chip in $(seq 0 11)
	do
		GPU_FREQ[${chip}]=$(geopmread GPU_CORE_FREQUENCY_STATUS gpu_chip $chip )
	done

	# Reporting data to ${OUT_POWER}
	echo "Runtime: ${RUNTIME} s" &>> ${OUT_POWER}
	echo "App exit: ${APP_RC}" &>> ${OUT_POWER}
	echo "Board Energy Start: $EnergyStart, End: $EnergyEnd, Used: $((EnergyEnd - EnergyStart))" &>> ${OUT_POWER}
	GPU_EnergyStart_all=0
	GPU_EnergyEnd_all=0
        for chip in $(seq 0 11)
        do
		INT_GPU_E=$(printf "%.0f" "${GPU_EnergyStart[${chip}]}")
		((GPU_EnergyStart_all += INT_GPU_E))
		INT_GPU_E=$(printf "%.0f" "${GPU_EnergyEnd[${chip}]}")
		((GPU_EnergyEnd_all += INT_GPU_E))
        done
	echo "GPU_CHIP All, GPU Energy start: $GPU_EnergyStart_all, End: $GPU_EnergyEnd_all, Energy used: $((GPU_EnergyEnd_all - GPU_EnergyStart_all))" &>> ${OUT_POWER}
        for chip in $(seq 0 11)
        do
		echo "  GPU_CHIP $chip, GPU Energy start: ${GPU_EnergyStart[${chip}]}, End: ${GPU_EnergyEnd[${chip}]}" &>> ${OUT_POWER}
        done

	echo "GPU_CORE_FREQUENCY_STATUS: ${GPU_FREQ[@]} " &>> ${OUT_POWER}

done

# Post-processing: summarize energy / runtime / average power per frequency
python3 ./parse_power.py ${OUT_POWER} &>> ${OUTDIR}/summary.${jobid}.txt

mv Power_Measurement.o${jobid} ${OUTDIR}/ 2>/dev/null || true
