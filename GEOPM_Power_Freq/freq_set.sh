#!/bin/bash

if [ "$#" -eq 0 ]; then
    FREQ=1500
else
    FREQ=$1
fi

for CARD in card{0..5}
do
    DEVPATH=/sys/class/drm/${CARD}
    # do this a few times, since min/max/boost needs to all align to same freq
    for j in {1..5}
    do
        echo $FREQ > ${DEVPATH}/gt_min_freq_mhz
	echo $FREQ > ${DEVPATH}/gt_boost_freq_mhz
	echo $FREQ > ${DEVPATH}/gt_max_freq_mhz
	for GT in ${DEVPATH}/gt/gt*
	do
	    echo $FREQ > "${GT}/rps_min_freq_mhz"
	    echo $FREQ > "${GT}/rps_max_freq_mhz"
	    echo $FREQ > "${GT}/rps_boost_freq_mhz"
	done
	sleep 0.1
    done
done

