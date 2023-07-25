#!/bin/bash

cd "$(dirname $0)"

for EPOCHNUM in 20 40 60 80 100 120 200
do
	./assess_predictions_in_directory.bash ./output/validation/epoch${EPOCHNUM} ./input/validation/epoch${EPOCHNUM}.pth
	./assess_predictions_in_directory.bash ./output/training/epoch${EPOCHNUM} ./input/training/epoch${EPOCHNUM}.pth
done

for SETNAME in validation training
do
	montage $(find ./output/${SETNAME}/ -type f -name 'all_pairs.png' | sort -V) -geometry +0+0 -tile 3x ./output/plots_of_${SETNAME}_pairs.png
done
