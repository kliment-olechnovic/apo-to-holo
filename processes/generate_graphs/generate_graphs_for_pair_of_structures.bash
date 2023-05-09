#!/bin/bash

cd "$(dirname $0)"

APO_FILE="$1"
HOLO_FILE="$2"

APO_NAME="$(basename ${APO_FILE} .pdb)"
HOLO_NAME="$(basename ${HOLO_FILE} .pdb)"

mkdir -p ./output/graphs/apo
mkdir -p ./output/graphs/holo

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

voronota_construct_contacts('-probe', 2.8, '-adjunct-solvent-direction', '-calculate-bounding-arcs');

voronota_voromqa_global("-adj-atom-sas-potential", "voromqa_sas_potential", "-adj-contact-energy", "voromqa_energy", "-smoothing-window", 0);

voronota_cad_score('-target', 'apo', '-model', 'holo', '-t-adj-residue', 'cadscore', '-m-adj-residue', 'cadscore', '-smoothing-window', 0);
voronota_set_adjunct_of_atoms_by_expression('-expression', '_linear_combo', '-input-adjuncts', 'cadscore', '-parameters', [-1.0, 1.0], '-output-adjunct', 'ground_truth');

voronota_set_adjunct_of_atoms_by_type_number("-name atom_type -typing-mode protein_atom");
voronota_set_adjunct_of_atoms_by_type_number("-name residue_type -typing-mode protein_residue");

voronota_set_adjunct_of_atoms_by_contact_areas("-use [-solvent] -name sas_area");
voronota_set_adjunct_of_atoms_by_contact_adjuncts('[-solvent]', '-source-name', 'solvdir_x', '-destination-name', 'solvdir_x', '-pooling-mode', 'min');
voronota_set_adjunct_of_atoms_by_contact_adjuncts('[-solvent]', '-source-name', 'solvdir_y', '-destination-name', 'solvdir_y', '-pooling-mode', 'min');
voronota_set_adjunct_of_atoms_by_contact_adjuncts('[-solvent]', '-source-name', 'solvdir_z', '-destination-name', 'solvdir_z', '-pooling-mode', 'min');

voronota_auto_assert_full_success=false;
voronota_set_adjunct_of_atoms("-use [-v! sas_area] -name sas_area -value 0");
voronota_set_adjunct_of_atoms("-use [-v! solvdir_x] -name solvdir_x -value 0");
voronota_set_adjunct_of_atoms("-use [-v! solvdir_y] -name solvdir_y -value 0");
voronota_set_adjunct_of_atoms("-use [-v! solvdir_z] -name solvdir_z -value 0");
voronota_set_adjunct_of_atoms("-use [-v! voromqa_sas_potential] -name voromqa_sas_potential -value 0");
voronota_auto_assert_full_success=true;

voronota_set_adjunct_of_atoms_by_expression("-use [] -expression _multiply -input-adjuncts voromqa_sas_potential sas_area -output-adjunct voromqa_sas_energy");

voronota_set_adjunct_of_contacts("-use [] -name seq_sep_class -value 5");
voronota_set_adjunct_of_contacts("-use [] -name covalent_bond -value 0");

voronota_auto_assert_full_success=false;
voronota_set_adjunct_of_contacts("-use [-min-seq-sep 0 -max-seq-sep 0] -name seq_sep_class -value 0");
voronota_set_adjunct_of_contacts("-use [-min-seq-sep 1 -max-seq-sep 1] -name seq_sep_class -value 1");
voronota_set_adjunct_of_contacts("-use [-min-seq-sep 2 -max-seq-sep 2] -name seq_sep_class -value 2");
voronota_set_adjunct_of_contacts("-use [-min-seq-sep 3 -max-seq-sep 3] -name seq_sep_class -value 3");
voronota_set_adjunct_of_contacts("-use [-min-seq-sep 4 -max-seq-sep 4] -name seq_sep_class -value 4");
voronota_set_adjunct_of_contacts("-use ([-max-seq-sep 0 -max-dist 1.8] or [-min-seq-sep 1 -max-seq-sep 1 -a1 [-aname N] -a2 [-aname C] -max-dist 1.8]) -name covalent_bond -value 1");
voronota_set_adjunct_of_contacts("-use [-v! voromqa_energy] -name voromqa_energy -value 0");
voronota_auto_assert_full_success=true;

voronota_unpick_objects();

var modes=['apo', 'holo'];
var titles=[params.apo_name, params.holo_name];

for(var i=0;i<modes.length;i++)
{
	var mode=modes[i];
	var title=titles[i];
	
	voronota_pick_objects('-names', [mode]);
	
	var file_prefix='./output/graphs/'+mode+'/'+title;
	
	voronota_export_atoms('-as-pdb', '-file', file_prefix+'.pdb', '-pdb-b-factor', 'ground_truth');
	
	voronota_export_adjuncts_of_atoms('-file', file_prefix+'_nodes.csv', '-use', '[]', '-no-serial', '-adjuncts', ['atom_index', 'residue_index', 'atom_type', 'residue_type', 'sas_area', 'voromqa_sas_energy', 'voromqa_score_a', 'voromqa_score_r', 'solvdir_x', 'solvdir_y', 'solvdir_z', 'ground_truth'], '-sep', ',');

	voronota_export_adjuncts_of_contacts('-file', file_prefix+'_links.csv', '-atoms-use', '[]', '-contacts-use', '[-no-solvent]', '-no-serial', '-adjuncts', ['atom_index1', 'atom_index2', 'area', 'boundary', 'distance', 'voromqa_energy', 'seq_sep_class', 'covalent_bond'], '-sep', ',');
}
EOF
} \
| ../../tools/voronota-js

