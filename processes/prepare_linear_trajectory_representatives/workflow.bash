#!/bin/bash

cd "$(dirname $0)"

if [ -d "./output/structures" ]
then
	echo "Presence of file './output/structures' indicates that everything is generated"
	exit 0
fi

cat ../prepare_pairs_of_structures/output/prepaired_pairs.txt | tail -n +2 \
| while read -r APO_PDBID APO_CHAIN HOLO_PDBID HOLO_CHAIN
do
	echo \
	  "../prepare_pairs_of_structures/output/structures/${APO_PDBID}_${APO_CHAIN}__${HOLO_PDBID}_${HOLO_CHAIN}/${APO_PDBID}_${APO_CHAIN}.pdb" \
	  "../prepare_pairs_of_structures/output/structures/${APO_PDBID}_${APO_CHAIN}__${HOLO_PDBID}_${HOLO_CHAIN}/${HOLO_PDBID}_${HOLO_CHAIN}.pdb"
done \
| xargs -L 1 -P 8 ./generate_representative_for_pair_of_structures.bash

