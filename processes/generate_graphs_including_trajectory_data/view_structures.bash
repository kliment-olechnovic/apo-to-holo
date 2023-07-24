#!/bin/bash

cd "$(dirname $0)"

CATEGORY="$1"

if [ -z "$CATEGORY" ]
then
	"$0" apo &
	"$0" holo &
	"$0" trajrep &
	exit 0
fi

cat ../prepare_pairs_of_structures/output/prepaired_pairs.txt | tail -n +2 \
| while read -r APO_PDBID APO_CHAIN HOLO_PDBID HOLO_CHAIN
do
	if [ "$CATEGORY" == "apo" ]
	then
		echo "./output/graphs/apo/${APO_PDBID}_${APO_CHAIN}.pdb"
	fi
	
	if [ "$CATEGORY" == "holo" ]
	then
		echo "./output/graphs/holo/${HOLO_PDBID}_${HOLO_CHAIN}.pdb"
	fi
	
	if [ "$CATEGORY" == "trajrep" ]
	then
		echo "./output/graphs/trajrep/${APO_PDBID}_${APO_CHAIN}__${HOLO_PDBID}_${HOLO_CHAIN}.pdb"
	fi
done \
| xargs voronota-gl

