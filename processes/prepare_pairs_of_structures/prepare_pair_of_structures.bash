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

voronota_fetch(params.apo_pdbid, '-assembly', 0);
voronota_fetch(params.holo_pdbid, '-assembly', 0);

voronota_unpick_objects();

voronota_restrict_atoms('[-t! het]', '-on-objects', params.apo_pdbid);
voronota_restrict_atoms('[-t! het]', '-on-objects', params.holo_pdbid);

voronota_restrict_atoms('[-chain '+params.apo_chain+']', '-on-objects', params.apo_pdbid);
voronota_restrict_atoms('[-chain '+params.holo_chain+']', '-on-objects', params.holo_pdbid);

for(var i=0;i<10;i++)
{
	voronota_export_sequence('-file', '_virtual/seq1', '-not-fill-start-gaps', '-not-fill-middle-gaps', '-on-objects', params.holo_pdbid);
	voronota_set_chain_residue_numbers_by_sequence('-sequence-file', '_virtual/seq1', '-on-objects', params.apo_pdbid);
	
	voronota_export_sequence('-file', '_virtual/seq2', '-not-fill-start-gaps', '-not-fill-middle-gaps', '-on-objects', params.apo_pdbid);
	voronota_set_chain_residue_numbers_by_sequence('-sequence-file', '_virtual/seq2', '-on-objects', params.holo_pdbid);
}

voronota_set_chain_residue_numbers_by_sequence('-sequence-file', '_virtual/seq2', '-on-objects', params.apo_pdbid);
voronota_set_chain_residue_numbers_by_sequence('-sequence-file', '_virtual/seq2', '-on-objects', params.holo_pdbid);

voronota_pick_objects();

var seq_info=voronota_print_sequence();
var segments1=seq_info.results[0].output.chains[0].segment_lengths;
var segments2=seq_info.results[1].output.chains[0].segment_lengths;

if(segments1.length!=1 || segments2.length!=1)
{
	throw ("Multiple segements after renumbering "+params.apo_pdbid+" "+params.holo_pdbid);
}

if(segments1[0]!=segments2[0])
{
	throw ("Mismatched length of segements after renumbering "+params.apo_pdbid+" "+params.holo_pdbid+": "+segments1[0]+" != "+segments2[0]);
}

voronota_center_atoms();

voronota_unpick_objects();

voronota_tmalign('-target', params.apo_pdbid, '-model', params.holo_pdbid);

var outdir=(params.apo_pdbid+'_'+params.apo_chain+'__'+params.holo_pdbid+'_'+params.holo_chain);

shell('mkdir -p '+outdir);

voronota_export_atoms('-as-pdb', '-file', outdir+'/'+params.apo_pdbid+'_'+params.apo_chain+'.pdb', '-on-objects', params.apo_pdbid);
voronota_export_atoms('-as-pdb', '-file', outdir+'/'+params.holo_pdbid+'_'+params.holo_chain+'.pdb', '-on-objects', params.holo_pdbid);

EOF
} \
| voronota-js

