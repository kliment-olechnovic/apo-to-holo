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

R --vanilla --args "$INNAME" << 'EOF' &> /dev/null
args=commandArgs(TRUE);
inname=args[1];
dt=read.table("all_pairs.txt", stringsAsFactors=FALSE, header=FALSE);
x=dt$V1;
y=dt$V2;
mean_x=0.18494;
sd_x=0.14343;
zx=(x-mean_x)/sd_x;
zy=(y-mean_x)/sd_x;
w=1+4*x;
ae=abs(zx-zy);
mae=mean(ae);
mwae=sum(ae*w)/sum(w);
corcoef=cor(x, y);
mcc_coefs=c();
for(xthreshold in seq(0.1, 0.7, 0.05))
{
	binx=x;
	binx[which(x<xthreshold)]=0.0;
	binx[which(x>=xthreshold)]=1.0;
	for(ythreshold in seq(0.1, 0.7, 0.05))
	{
		biny=y;
		biny[which(y<ythreshold)]=0.0;
		biny[which(y>=ythreshold)]=1.0;
		mcc_coefs=c(mcc_coefs, cor(binx, biny));
	}
}
max_mcc=max(mcc_coefs[which(is.finite(mcc_coefs))]);
png("./all_pairs.png", height=5, width=6, units="in", res=200);
plot(x=x, y=y, xlab="ground truth value", ylab="predicted value", main=paste0(inname, ", truth vs predicted: CC=", format(corcoef, digits=4), " ;\n MWAE=", format(mwae, digits=4), " ; MAE=", format(mae, digits=4), " ; max_MCC=", format(max_mcc, digits=4)), col=densCols(dt$V1, dt$V2));
dev.off();
result=data.frame(CC=corcoef, WMAE=mwae, MAE=mae, max_MCC=max_mcc);
write.table(result, file="./all_pairs_summary_scores.txt", quote=FALSE, row.names=FALSE, sep=" ");
EOF

EPOCHNUM="$(echo ${INNAME} | sed 's/epoch//' | sed 's/.pth//')"
EXPERIMENTNAME="$(basename $(dirname $(dirname ${INDIR})))"

{
cat ./all_pairs_summary_scores.txt | head -1 | sed 's|^|experiment epoch |'
cat ./all_pairs_summary_scores.txt | tail -n +2 | sed "s|^|${EXPERIMENTNAME} ${EPOCHNUM} |"
} \
| sponge "./all_pairs_summary_scores.txt"






