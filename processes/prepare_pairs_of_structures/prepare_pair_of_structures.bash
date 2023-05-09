#!/bin/bash

cd "$(dirname $0)"

APO_PDBID="$1"
APO_CHAIN="$2"
HOLO_PDBID="$3"
HOLO_CHAIN="$4"

mkdir -p ./output/structures

cd ./output/structures

{
cat << EOF
var params={}
params.apo_pdbid='$APO_PDBID';
params.apo_chain='$APO_CHAIN';
params.holo_pdbid='$HOLO_PDBID';
params.holo_chain='$HOLO_CHAIN';
EOF

cat << 'EOF'
voronota_auto_assert_full_success=true;

var apo_id=params.apo_pdbid+'_'+params.apo_chain;
var holo_id=params.holo_pdbid+'_'+params.holo_chain;

voronota_fetch(params.apo_pdbid, '-assembly', 0);
voronota_rename_object(params.apo_pdbid, apo_id);

voronota_fetch(params.holo_pdbid, '-assembly', 0);
voronota_rename_object(params.holo_pdbid, holo_id);

voronota_unpick_objects();

voronota_restrict_atoms('[-t! het -protein]', '-on-objects', apo_id);
voronota_restrict_atoms('[-t! het -protein]', '-on-objects', holo_id);

voronota_restrict_atoms('[-chain '+params.apo_chain+']', '-on-objects', apo_id);
voronota_restrict_atoms('[-chain '+params.holo_chain+']', '-on-objects', holo_id);

for(var i=0;i<10;i++)
{
	voronota_export_sequence('-file', '_virtual/seq1', '-not-fill-start-gaps', '-not-fill-middle-gaps', '-on-objects', holo_id);
	voronota_set_chain_residue_numbers_by_sequence('-sequence-file', '_virtual/seq1', '-on-objects', apo_id);
	
	voronota_export_sequence('-file', '_virtual/seq2', '-not-fill-start-gaps', '-not-fill-middle-gaps', '-on-objects', apo_id);
	voronota_set_chain_residue_numbers_by_sequence('-sequence-file', '_virtual/seq2', '-on-objects', holo_id);
}

voronota_set_chain_residue_numbers_by_sequence('-sequence-file', '_virtual/seq2', '-on-objects', apo_id);
voronota_set_chain_residue_numbers_by_sequence('-sequence-file', '_virtual/seq2', '-on-objects', holo_id);

voronota_pick_objects();

var seq_info=voronota_print_sequence();
var segments1=seq_info.results[0].output.chains[0].segment_lengths;
var segments2=seq_info.results[1].output.chains[0].segment_lengths;

if(segments1.length!=1 || segments2.length!=1)
{
	throw ("Multiple segements after renumbering "+apo_id+" "+holo_id);
}

if(segments1[0]!=segments2[0])
{
	throw ("Mismatched length of segements after renumbering "+apo_id+" "+holo_id+": "+segments1[0]+" != "+segments2[0]);
}

voronota_center_atoms();

voronota_unpick_objects();

voronota_tmalign('-target', apo_id, '-model', holo_id);

var outdir=(apo_id+'__'+holo_id);

shell('mkdir -p '+outdir);

voronota_export_atoms('-as-pdb', '-file', outdir+'/'+apo_id+'.pdb', '-on-objects', apo_id);
voronota_export_atoms('-as-pdb', '-file', outdir+'/'+holo_id+'.pdb', '-on-objects', holo_id);

EOF
} \
| voronota-js

