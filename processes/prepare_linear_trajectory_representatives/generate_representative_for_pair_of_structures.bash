#!/bin/bash

cd "$(dirname $0)"

APO_FILE="$1"
HOLO_FILE="$2"

APO_NAME="$(basename ${APO_FILE} .pdb)"
HOLO_NAME="$(basename ${HOLO_FILE} .pdb)"

mkdir -p ./output/structures

{
cat << EOF
var params={}
params.apo_file='$APO_FILE';
params.holo_file='$HOLO_FILE';
params.apo_name='$APO_NAME';
params.holo_name='$HOLO_NAME';
EOF

cat << 'EOF'
voronota_auto_assert_full_success=true;

voronota_import('-file', params.apo_file, '-title', 'apo');
voronota_import('-file', params.holo_file, '-title', 'holo');

voronota_pick_objects();

voronota_set_chain_name('-chain-name', 'A');

voronota_faspr('-lib-path', '../../tools');

var seq_info=voronota_print_sequence();
var segments1=seq_info.results[0].output.chains[0].segment_lengths;
var segments2=seq_info.results[1].output.chains[0].segment_lengths;

if(segments1.length!=1 || segments2.length!=1)
{
	throw ("Multiple segements for "+params.apo_pdbid+" "+params.holo_pdbid);
}

if(segments1[0]!=segments2[0])
{
	throw ("Mismatched length of segements for "+params.apo_name+" "+params.holo_name+": "+segments1[0]+" != "+segments2[0]);
}

voronota_restrict_atoms('[-aname C,CA,N,O]');

voronota_center_atoms();

voronota_qcprot('-target', 'apo', '-model', 'holo');

var rmsd=voronota_last_output().results[0].output.rmsd;

writeln("RMSD for "+params.apo_name+" "+params.holo_name+" = "+rmsd);

if(rmsd<2.5)
{
	throw ("RMSD <2.5 for "+params.apo_name+" "+params.holo_name);
}

voronota_summarize_two_state_motion('-first', 'apo', '-second', 'holo', '-result', 'representative');

voronota_delete_objects('-names', ['apo', 'holo']);

voronota_pick_objects('-names', ['representative']);

//voronota_faspr('-lib-path', '../../tools');

voronota_export_atoms('-as-pdb', '-file', './output/structures/'+params.apo_name+'__'+params.holo_name+'.pdb');
EOF
} \
| ../../tools/voronota-js

