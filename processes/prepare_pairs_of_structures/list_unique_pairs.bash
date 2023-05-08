#!/bin/bash

cd "$(dirname $0)"

readonly TMPLDIR=$(mktemp -d)
trap "rm -r $TMPLDIR" EXIT


{
cat ./input/cryptosite_apo_holo_pair_ids.txt | tail -n +2 | awk '{print $1 " " $2 " " $3 " " $4}'
cat ./input/pocketminer_apo_holo_pair_ids.txt | tail -n +2 | awk '{print $1 " " $2 " " $4 " " $5}'
} \
| sort \
| uniq \
> "${TMPLDIR}/raw_pairs"

cat "${TMPLDIR}/raw_pairs" | awk '{print $1}' | sort | uniq -c | awk '{if($1==1){print $2}}' > "${TMPLDIR}/ids_apo"
cat "${TMPLDIR}/raw_pairs" | awk '{print $3}' | sort | uniq -c | awk '{if($1==1){print $2}}' > "${TMPLDIR}/ids_holo"

cat "${TMPLDIR}/raw_pairs" | grep -f "${TMPLDIR}/ids_apo" | grep -f "${TMPLDIR}/ids_holo" > "${TMPLDIR}/final_pairs"

mkdir -p ./output

{
echo apo_pdb_id apo_chain_id holo_pdb_id holo_chain_id
cat "${TMPLDIR}/final_pairs"
} \
> ./output/candidate_pairs.txt

