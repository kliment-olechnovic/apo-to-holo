#!/bin/bash

cd "$(dirname $0)"

OUTDIR="$1"
INDIR="$2"

if [ -z "$INDIR" ] || [ ! -d "$INDIR" ]
then
	echo "Missing input directory"
	exit 1
fi

INNAME="$(basename ${INDIR})"

OUTDIR="${OUTDIR}"

mkdir -p "$OUTDIR"

mkdir -p "${OUTDIR}/predictions"

find "${INDIR}/" -type f | sort | xargs cp -t "${OUTDIR}/predictions"

find "${OUTDIR}/predictions/" -type f \
| while read -r PREDFILE
do
	cat "$PREDFILE" | awk '{print ($1*0.14343)+0.18494}' | sponge "$PREDFILE"
done

mkdir -p "${OUTDIR}/groundtruth"

find "${OUTDIR}/predictions/" -type f | xargs -L 1 basename | sort \
| while read ID
do
	cat "../generate_coarse_grained_graphs/output/graphs/apo/${ID}_nodes.csv" | tr ',' ' ' | awk '{print $NF}' | tail -n +2 > "${OUTDIR}/groundtruth/${ID}"
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
	cat "../generate_coarse_grained_graphs/output/graphs/apo/${ID}_nodes.csv" | tr ',' ' ' | grep -v ground \
	| awk '{print "c<" $1 ">r<" $2 ">R<" $6 ">A<CA> " $12 " " $13 " " $14 " " $15 " . gt=" $NF}' \
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

cd "${OUTDIR}/pairs/"

R --vanilla << 'EOF' &> /dev/null
dt=read.table("all_pairs.txt", stringsAsFactors=FALSE, header=FALSE);
x=dt$V1;
y=dt$V2;
zx=(x-mean(x))/sd(x);
zy=(y-mean(x))/sd(x);
w=1+4*x;
ae=abs(zx-zy);
mae=mean(ae);
mwae=sum(ae*w)/sum(w);
corcoef=cor(x, y);
png("./all_pairs.png", height=5, width=10, units="in", res=200);
plot(x=x, y=y, xlab="ground truth value", ylab="predicted value", main=paste0("ground truth vs predicted values\nCC=", corcoef, " ; MWAE=", mwae, " ; MAE=", mae), col=densCols(dt$V1, dt$V2));
dev.off();
result=data.frame(CC=corcoef, WMAE=wmae, MAE=mae);
EOF








