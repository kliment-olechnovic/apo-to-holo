#!/bin/bash

cd "$(dirname $0)"

find ./input/ -mindepth 3 -maxdepth 3 -type d | sort -V \
| while read INDIR
do
	OUTDIR="$(echo ${INDIR} | sed 's|/input/|/output/|')"
	./assess_predictions_in_directory.bash "$OUTDIR" "$INDIR"
done

find ./output/ -mindepth 2 -maxdepth 2 -type d | sort -V \
| while read OUTDIR
do
	SETNAME="$(basename ${OUTDIR})"
	montage $(find ${OUTDIR}/ -type f -name 'all_pairs.png' | sort -V) -geometry +0+0 -tile 3x ${OUTDIR}/../plots_of_pairs_from_${SETNAME}.png
done

./summarize_output.bash

