#!/bin/bash

cd "$(dirname $0)"

./list_unique_pairs.bash

cat ./output/candidate_pairs.txt | tail -n +2 | xargs -L 1 ./prepare_pair_of_structures.bash

