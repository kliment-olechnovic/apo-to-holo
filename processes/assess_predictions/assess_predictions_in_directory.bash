#!/bin/bash

cd "$(dirname $0)"

OUTDIR="$1"
INDIR="$2"

if [ -z "$INDIR" ] || [ ! -d "$INDIR" ]
then
	echo "Missing input director"
	exit 1
fi

INNAME="$(basename ${INDIR})"

OUTDIR="${OUTDIR}"

mkdir -p "$OUTDIR"

mkdir -p "${OUTDIR}/predictions"

find "${INDIR}/" -type f | sort | xargs cp -t "${OUTDIR}/predictions"

mkdir -p "${OUTDIR}/groundtruth"

find "${OUTDIR}/predictions/" -type f | xargs -L 1 basename | sort \
| while read ID
do
	cat "../generate_graphs/output/graphs/apo/${ID}_nodes.csv" | tr ',' ' ' | awk '{print $NF}' > "${OUTDIR}/groundtruth/${ID}"
done

mkdir -p "${OUTDIR}/pairs"

paste \
  <(find "${OUTDIR}/groundtruth/" -type f | sort | xargs cat | grep -v ground) \
  <(find "${OUTDIR}/predictions/" -type f | sort | xargs cat) \
> "${OUTDIR}/pairs/all_pairs.txt"

mkdir -p "${OUTDIR}/atoms_gt"
find "${OUTDIR}/predictions/" -type f | xargs -L 1 basename | sort \
| while read ID
do 
	cat "../generate_graphs/output/graphs/apo/${ID}_nodes.csv" | tr ',' ' ' | grep -v ground \
	| awk '{print "c<" $1 ">r<" $2 ">R<" $6 ">A<" $7 "> " $12 " " $13 " " $14 " " $15 " . gt=" $NF}' \
	> "${OUTDIR}/atoms_gt/${ID}.pa"
done

mkdir -p "${OUTDIR}/atoms_pairs"
find "${OUTDIR}/predictions/" -type f | xargs -L 1 basename | sort \
| while read ID
do
	paste "${OUTDIR}/atoms_gt/${ID}.pa" "${OUTDIR}/predictions/${ID}" \
	| sed 's|\t\s*|;tf=|' \
	> "${OUTDIR}/atoms_pairs/${ID}.pa"
done









