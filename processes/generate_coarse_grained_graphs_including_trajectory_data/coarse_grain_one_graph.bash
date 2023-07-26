#!/bin/bash

OUTDIR="$1"
INFILE_NODES="$2"

if [ ! -s "$INFILE_NODES" ]
then
	echo "Missing input nodes file"
	exit 1
fi

INFILE_LINKS="$(echo ${INFILE_NODES} | sed 's|_nodes.csv|_links.csv|')"

if [ ! -s "$INFILE_LINKS" ]
then
	echo "Missing input links file"
	exit 1
fi

OUTFILE_NODES="${OUTDIR}/$(basename ${INFILE_NODES})"
OUTFILE_LINKS="${OUTDIR}/$(basename ${INFILE_LINKS})"

mkdir -p "$OUTDIR"

R --vanilla --args "$INFILE_NODES" "$INFILE_LINKS" "$OUTFILE_NODES" "$OUTFILE_LINKS" << 'EOF' > /dev/null
args=commandArgs(TRUE);
infile_nodes=args[1];
infile_links=args[2];
outfile_nodes=args[3];
outfile_links=args[4];

dt_nodes=read.table(infile_nodes, sep=",", header=TRUE, stringsAsFactors=FALSE);
dt_links=read.table(infile_links, sep=",", header=TRUE, stringsAsFactors=FALSE);

dt_nodes$cdt_node_id=paste(dt_nodes$ID_chainID, dt_nodes$ID_resSeq, dt_nodes$ID_iCode, sep="_");
dt_nodes=dt_nodes[order(dt_nodes$cdt_node_id),];
cdt_nodes=dt_nodes[!duplicated(dt_nodes$cdt_node_id),];
cdt_nodes=cdt_nodes[order(cdt_nodes$ID_chainID, cdt_nodes$ID_resSeq, cdt_nodes$ID_iCode),];

cdt_nodes$ID_serial=".";
cdt_nodes$ID_altLoc=".";
cdt_nodes$ID_name=".";
cdt_nodes$atom_index=(1:nrow(cdt_nodes))-1;
cdt_nodes$residue_index=cdt_nodes$atom_index;
cdt_nodes$atom_type=cdt_nodes$residue_type;
for(i in 1:nrow(cdt_nodes))
{
	rdt=dt_nodes[which(dt_nodes$cdt_node_id==cdt_nodes$cdt_node_id[i]),];
	cdt_nodes$center_x[i]=mean(rdt$center_x);
	cdt_nodes$center_y[i]=mean(rdt$center_y);
	cdt_nodes$center_z[i]=mean(rdt$center_z);
	cdt_nodes$radius[i]=max(rdt$radius);
	cdt_nodes$voromqa_sas_potential[i]=max(rdt$voromqa_sas_potential);
	cdt_nodes$residue_mean_sas_potential[i]=mean(rdt$residue_mean_sas_potential);
	cdt_nodes$residue_sum_sas_potential[i]=mean(rdt$residue_sum_sas_potential);
	cdt_nodes$residue_size[i]=mean(rdt$residue_size);
	cdt_nodes$sas_area[i]=sum(rdt$sas_area);
	cdt_nodes$solvdir_x[i]=mean(rdt$solvdir_x);
	cdt_nodes$solvdir_y[i]=mean(rdt$solvdir_y);
	cdt_nodes$solvdir_z[i]=mean(rdt$solvdir_z);
	cdt_nodes$voromqa_sas_energy[i]=sum(rdt$voromqa_sas_energy);
	cdt_nodes$voromqa_depth[i]=mean(rdt$voromqa_depth);
	cdt_nodes$voromqa_score_a[i]=mean(rdt$voromqa_score_a);
	cdt_nodes$voromqa_score_r[i]=mean(rdt$voromqa_score_r);
	cdt_nodes$volume[i]=sum(rdt$volume);
	cdt_nodes$volume_vdw[i]=sum(rdt$volume_vdw);
	cdt_nodes$ufsr_a1[i]=mean(rdt$ufsr_a1);
	cdt_nodes$ufsr_a2[i]=mean(rdt$ufsr_a2);
	cdt_nodes$ufsr_a3[i]=mean(rdt$ufsr_a3);
	cdt_nodes$ufsr_b1[i]=mean(rdt$ufsr_b1);
	cdt_nodes$ufsr_b2[i]=mean(rdt$ufsr_b2);
	cdt_nodes$ufsr_b3[i]=mean(rdt$ufsr_b3);
	cdt_nodes$ufsr_c1[i]=mean(rdt$ufsr_c1);
	cdt_nodes$ufsr_c2[i]=mean(rdt$ufsr_c2);
	cdt_nodes$ufsr_c3[i]=mean(rdt$ufsr_c3);
	cdt_nodes$ev28[i]=mean(rdt$ev28);
	cdt_nodes$ev56[i]=mean(rdt$ev56);
	cdt_nodes$trajdiff[i]=mean(rdt$trajdiff);
	cdt_nodes$ground_truth[i]=mean(rdt$ground_truth);
}

dt_links$cdt_link_id1=paste(dt_links$ID1_chainID, dt_links$ID1_resSeq, dt_links$ID1_iCode, sep="_");
dt_links$cdt_link_id2=paste(dt_links$ID2_chainID, dt_links$ID2_resSeq, dt_links$ID2_iCode, sep="_");
dt_links$cdt_link_id=paste(dt_links$cdt_link_id1, dt_links$cdt_link_id2, sep="__");
dt_links=dt_links[order(dt_links$cdt_link_id),];
cdt_links=dt_links[!duplicated(dt_links$cdt_link_id),];
cdt_links=cdt_links[order(cdt_links$ID1_chainID, cdt_links$ID1_resSeq, cdt_links$ID1_iCode, cdt_links$ID2_chainID, cdt_links$ID2_resSeq, cdt_links$ID2_iCode),];

cdt_links$ID1_serial=".";
cdt_links$ID1_altLoc=".";
cdt_links$ID1_name=".";
cdt_links$ID2_serial=".";
cdt_links$ID2_altLoc=".";
cdt_links$ID2_name=".";
for(i in 1:nrow(cdt_links))
{
	rdt=dt_links[which(dt_links$cdt_link_id==cdt_links$cdt_link_id[i]),];
	cdt_links$atom_index1[i]=cdt_nodes$atom_index[which(cdt_nodes$cdt_node_id==cdt_links$cdt_link_id1[i])[1]];
	cdt_links$atom_index2[i]=cdt_nodes$atom_index[which(cdt_nodes$cdt_node_id==cdt_links$cdt_link_id2[i])[1]];
	cdt_links$area[i]=sum(rdt$area);
	cdt_links$boundary[i]=sum(rdt$boundary);
	cdt_links$distance[i]=min(rdt$distance);
	cdt_links$voromqa_energy[i]=sum(rdt$voromqa_energy);
	cdt_links$seq_sep_class[i]=min(rdt$seq_sep_class);
	cdt_links$covalent_bond[i]=max(rdt$covalent_bond);
	cdt_links$hbond[i]=max(rdt$hbond);
}

cdt_links=cdt_links[which(cdt_links$cdt_link_id1!=cdt_links$cdt_link_id2),];

out_nodes_columns=c("ID_chainID", "ID_resSeq", "ID_iCode", "ID_serial", "ID_altLoc", "ID_resName", "ID_name", "atom_index", "residue_index", "atom_type", "residue_type", "center_x", "center_y", "center_z", "radius", "voromqa_sas_potential", "residue_mean_sas_potential", "residue_sum_sas_potential", "residue_size", "sas_area", "solvdir_x", "solvdir_y", "solvdir_z", "voromqa_sas_energy", "voromqa_depth", "voromqa_score_a", "voromqa_score_r", "volume", "volume_vdw", "ufsr_a1", "ufsr_a2", "ufsr_a3", "ufsr_b1", "ufsr_b2", "ufsr_b3", "ufsr_c1", "ufsr_c2", "ufsr_c3", "ev28", "ev56", "trajdiff", "ground_truth");

out_links_columns=c("ID1_chainID", "ID1_resSeq", "ID1_iCode", "ID1_serial", "ID1_altLoc", "ID1_resName", "ID1_name", "ID2_chainID", "ID2_resSeq", "ID2_iCode", "ID2_serial", "ID2_altLoc", "ID2_resName", "ID2_name", "atom_index1", "atom_index2", "area", "boundary", "distance", "voromqa_energy", "seq_sep_class", "covalent_bond", "hbond");

cdt_nodes=cdt_nodes[,out_nodes_columns];
cdt_links=cdt_links[,out_links_columns];

write.table(cdt_nodes, file=outfile_nodes, quote=FALSE, row.names=FALSE, sep=",");
write.table(cdt_links, file=outfile_links, quote=FALSE, row.names=FALSE, sep=",");

EOF

