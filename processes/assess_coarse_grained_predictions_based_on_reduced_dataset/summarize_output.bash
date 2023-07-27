#!/bin/bash

cd "$(dirname $0)"

mkdir -p "./summary_output"

find ./output/ -type f -name 'all_pairs_summary_scores.txt' \
| grep -v training \
| sort -V \
| xargs -L 1 cat \
| awk '{if(NR==1 || NR%2==0){print $0}}'  \
| column -t \
> ./summary_output/all_pairs_summary_scores.txt

cd ./summary_output

find ../input/ -type f -name 'evaluation_loss' | sort -V \
| while read ELFILE
do
	echo "${ELFILE} $(basename $(dirname ${ELFILE}))"
done \
> list_of_evaluation_loss_files.txt

R --vanilla << 'EOF' > /dev/null
dt=read.table("all_pairs_summary_scores.txt", stringsAsFactors=FALSE, header=TRUE);
max_epoch=max(dt$epoch);
experiments=union(dt$experiment, dt$experiment);
experiments_colors=c("#e6194b", "#3cb44b", "#ffe119", "#4363d8", "#f58231", "#911eb4", "#46f0f0", "#f032e6", "#bcf60c", "#fabebe", "#008080", "#e6beff", "#9a6324", "#fffac8", "#800000", "#aaffc3", "#808000", "#ffd8b1", "#000075", "#808080", "#000000")[1:length(experiments)];
scorenames=c("WMAE", "MAE", "CC", "max_MCC");
scorenames_pretty=c("Weighted MAE", "MAE", "Pearson CC", "max MCC");

png("./all_pairs_summary_scores.png", height=10, width=8, units="in", res=200);
par(mfrow=c(3, 2));
for(scorename_i in 1:length(scorenames))
{
	scorename=scorenames[scorename_i];
	scorename_pretty=scorenames_pretty[scorename_i];
	plot(x=dt$epoch, y=dt[,scorename], xlab="Epoch", ylab=scorename_pretty, main=scorename_pretty, type="n");
	for(experiment_i in 1:length(experiments))
	{
		experiment=experiments[experiment_i];
		experiment_color=experiments_colors[experiment_i];
		sdt=dt[which(dt$experiment==experiment),];
		sdt=sdt[order(sdt$epoch),];
		points(x=sdt$epoch, y=sdt[,scorename], type="l", col=experiment_color);
		points(x=sdt$epoch, y=sdt[,scorename], col=experiment_color);
	}
}
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1);
legend("topleft", legend=experiments, pch=16, pt.cex=3, cex=1.5, bty='n', col=experiments_colors);
dev.off();

for(scorename_i in 1:length(scorenames))
{
	scorename=scorenames[scorename_i];
	ocoef=ifelse(is.element(scorename, c("WMAE", "MAE")), 1.0, -1.0);
	reordered_dt=dt[order(dt[,scorename]*ocoef)[1:5],];
	write.table(reordered_dt, file=paste0("./all_pairs_summary_scores_top_by_", scorename, ".txt"), quote=FALSE, row.names=FALSE, sep=" ");
}

elfs_dt=read.table("list_of_evaluation_loss_files.txt", stringsAsFactors=FALSE, header=FALSE);
elfs=elfs_dt[[1]];
elfs_pretty=elfs_dt[[2]];
png("./evaluation_losses.png", height=10, width=10, units="in", res=200);
plot(x=c(1, 900), y=c(0.4, 1), xlab="Epoch", ylab="Loss, weighted MAE or (1-CC)", main="Weighted MAE losses on validation", type="n");
for(elf_i in 1:length(elfs))
{
	elf=elfs[elf_i];
	els=read.table(elf, stringsAsFactors=FALSE, header=FALSE)[[1]];
	points(x=1:length(els), y=els, type="l", col=experiments_colors[elf_i]);
}
legend("bottomleft", legend=elfs_pretty, pch=16, pt.cex=1.5, cex=1.1, bty='n', col=experiments_colors[1:length(elfs)]);
dev.off();
EOF

find ./ -type f -name 'all_pairs_summary_scores_top_by_*.txt' \
| while read TFILE
do
	cat "$TFILE" | column -t | sponge "$TFILE"
done

rm "./list_of_evaluation_loss_files.txt"


