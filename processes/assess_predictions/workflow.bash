#!/bin/bash

cd "$(dirname $0)"

for EPOCHNUM in 20 40 58 60
do
	./assess_predictions_in_directory.bash ./output/validation/epoch${EPOCHNUM} ./input/validation/epoch${EPOCHNUM}.pth
	./assess_predictions_in_directory.bash ./output/training/epoch${EPOCHNUM} ./input/training/epoch${EPOCHNUM}.pth
done
