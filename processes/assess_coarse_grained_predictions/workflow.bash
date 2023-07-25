#!/bin/bash

cd "$(dirname $0)"

for SETNAME in validation training
do
	find ./input/${SETNAME}/ -mindepth 1 -maxdepth 1 -type d | sort -V \
	| while read INDIR
	do
		OUTDIR="$(echo ${INDIR} | sed 's|/input/|/output/|')"
		./assess_predictions_in_directory.bash "$OUTDIR" "$INDIR"
	done
	
	montage $(find ./output/${SETNAME}/ -type f -name 'all_pairs.png' | sort -V) -geometry +0+0 -tile 3x ./output/plots_of_${SETNAME}_pairs.png
done

