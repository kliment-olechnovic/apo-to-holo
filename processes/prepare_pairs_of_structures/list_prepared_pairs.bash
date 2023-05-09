#!/bin/bash

cd "$(dirname $0)"

{
echo "apo_pdb_id apo_chain_id holo_pdb_id holo_chain_id"
ls ./output/structures/ | sort | sed 's/_\+/ /g'
} \
> ./output/prepaired_pairs.txt

