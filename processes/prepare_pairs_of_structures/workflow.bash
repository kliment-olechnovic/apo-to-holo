#!/bin/bash

cd "$(dirname $0)"

if [ -s "./output/prepaired_pairs.txt" ]
then
	echo "Presence of file './output/prepaired_pairs.txt' indicates that all pairs are prepared."
	exit 0
fi

./list_unique_pairs.bash

cat ./output/candidate_pairs.txt | tail -n +2 | xargs -L 1 -P 8 ./prepare_pair_of_structures.bash

./list_prepared_pairs.bash

