#!/bin/bash

cd "$(dirname $0)"

if [ -s "./output/graphs.tar.bz2" ]
then
	echo "Presence of file './output/graphs.tar.bz2' indicates that everything is generated and can be extracted with 'tar -xf ./graphs.tar.bz2'"
	exit 0
fi

cat ../prepare_pairs_of_structures/output/prepaired_pairs.txt | tail -n +2 \
| while read -r APO_PDBID APO_CHAIN HOLO_PDBID HOLO_CHAIN
do
	echo \
	  "../prepare_pairs_of_structures/output/structures/${APO_PDBID}_${APO_CHAIN}__${HOLO_PDBID}_${HOLO_CHAIN}/${APO_PDBID}_${APO_CHAIN}.pdb" \
	  "../prepare_pairs_of_structures/output/structures/${APO_PDBID}_${APO_CHAIN}__${HOLO_PDBID}_${HOLO_CHAIN}/${HOLO_PDBID}_${HOLO_CHAIN}.pdb"
done \
| xargs -L 1 -P 8 ./generate_graphs_for_pair_of_structures.bash

cd ./output
tar -cjf ./graphs.tar.bz2 ./graphs

