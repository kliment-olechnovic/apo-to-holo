#!/bin/bash

cd "$(dirname $0)"

APO_FILE="$1"
HOLO_FILE="$2"
TRAJREP_FILE="$3"

APO_NAME="$(basename ${APO_FILE} .pdb)"
HOLO_NAME="$(basename ${HOLO_FILE} .pdb)"
TRAJREP_NAME="$(basename ${TRAJREP_FILE} .pdb)"

mkdir -p ./output/cadscores
mkdir -p ./output/graphs/apo
mkdir -p ./output/graphs/holo
mkdir -p ./output/graphs/trajrep

{
cat << EOF
var params={}
params.apo_file='$APO_FILE';
params.holo_file='$HOLO_FILE';
params.trajrep_file='$TRAJREP_FILE';
params.apo_name='$APO_NAME';
params.holo_name='$HOLO_NAME';
params.trajrep_name='$TRAJREP_NAME';
EOF

cat << 'EOF'
voronota_auto_assert_full_success=true;

voronota_import('-file', params.apo_file, '-title', 'apo');
voronota_import('-file', params.holo_file, '-title', 'holo');
voronota_import('-file', params.trajrep_file, '-title', 'trajrep');

voronota_pick_objects();

voronota_set_chain_name('-chain-name', 'A');

voronota_faspr('-lib-path', '../../tools');

voronota_construct_contacts('-probe', 0.01);

voronota_set_adjunct_of_atoms_by_expression('-expression', '_linear_combo', '-input-adjuncts', 'volume', '-parameters', [1.0, 0.0], '-output-adjunct', 'volume_vdw');

voronota_delete_adjuncts_of_atoms('-adjuncts', ['volume']);

voronota_construct_contacts('-probe', 2.8, '-adjunct-solvent-direction', '-calculate-bounding-arcs', '-force');

voronota_voromqa_global("-adj-atom-sas-potential", "voromqa_sas_potential", "-adj-contact-energy", "voromqa_energy", "-smoothing-window", 0, "-adj-atom-quality", "voromqa_score_a", "-adj-residue-quality", "voromqa_score_r");

voronota_cad_score('-target', 'apo', '-model', 'holo', '-t-adj-residue', 'cadscore', '-m-adj-residue', 'cadscore', '-smoothing-window', 0);

var cadscores_file='./output/cadscores/'+params.apo_name+'__'+params.holo_name+'.txt';
voronota_export_adjuncts_of_atoms('-on-objects', ['apo'], '-file', cadscores_file, '-use', '[-aname CA]', '-no-serial', '-no-name', '-adjuncts', ['cadscore']);
voronota_import_adjuncts_of_atoms('-on-objects', ['trajrep'], '-file', cadscores_file);

voronota_set_adjunct_of_atoms_by_type_number("-name atom_type -typing-mode protein_atom");
voronota_set_adjunct_of_atoms_by_type_number("-name residue_type -typing-mode protein_residue");

voronota_set_adjunct_of_atoms_by_contact_areas("-use [-solvent] -name sas_area");
voronota_set_adjunct_of_atoms_by_contact_adjuncts('[-solvent]', '-source-name', 'solvdir_x', '-destination-name', 'solvdir_x', '-pooling-mode', 'min');
voronota_set_adjunct_of_atoms_by_contact_adjuncts('[-solvent]', '-source-name', 'solvdir_y', '-destination-name', 'solvdir_y', '-pooling-mode', 'min');
voronota_set_adjunct_of_atoms_by_contact_adjuncts('[-solvent]', '-source-name', 'solvdir_z', '-destination-name', 'solvdir_z', '-pooling-mode', 'min');

voronota_set_adjuncts_of_atoms_by_ufsr('[-aname CA]', '-name-prefix', 'mc_ufsr');
voronota_set_adjunct_of_atoms_by_residue_pooling('-source-name mc_ufsr_a1 -destination-name ufsr_a1 -pooling-mode max');
voronota_set_adjunct_of_atoms_by_residue_pooling('-source-name mc_ufsr_b1 -destination-name ufsr_b1 -pooling-mode max');
voronota_set_adjunct_of_atoms_by_residue_pooling('-source-name mc_ufsr_c1 -destination-name ufsr_c1 -pooling-mode max');
voronota_set_adjunct_of_atoms_by_residue_pooling('-source-name mc_ufsr_a2 -destination-name ufsr_a2 -pooling-mode max');
voronota_set_adjunct_of_atoms_by_residue_pooling('-source-name mc_ufsr_b2 -destination-name ufsr_b2 -pooling-mode max');
voronota_set_adjunct_of_atoms_by_residue_pooling('-source-name mc_ufsr_c2 -destination-name ufsr_c2 -pooling-mode max');
voronota_set_adjunct_of_atoms_by_residue_pooling('-source-name mc_ufsr_a3 -destination-name ufsr_a3 -pooling-mode max');
voronota_set_adjunct_of_atoms_by_residue_pooling('-source-name mc_ufsr_b3 -destination-name ufsr_b3 -pooling-mode max');
voronota_set_adjunct_of_atoms_by_residue_pooling('-source-name mc_ufsr_c3 -destination-name ufsr_c3 -pooling-mode max');

voronota_describe_exposure("-adj-atom-exposure-value ev28 -probe-min 2.8 -probe-max 30 -expansion 1 -smoothing-iterations 0 -smoothing-depth 0");
voronota_describe_exposure("-adj-atom-exposure-value ev56 -probe-min 5.6 -probe-max 30 -expansion 1 -smoothing-iterations 0 -smoothing-depth 0");

voronota_auto_assert_full_success=false;
voronota_set_adjunct_of_atoms("-use [-v! sas_area] -name sas_area -value 0");
voronota_set_adjunct_of_atoms("-use [-v! solvdir_x] -name solvdir_x -value 0");
voronota_set_adjunct_of_atoms("-use [-v! solvdir_y] -name solvdir_y -value 0");
voronota_set_adjunct_of_atoms("-use [-v! solvdir_z] -name solvdir_z -value 0");
voronota_set_adjunct_of_atoms("-use [-v! voromqa_sas_potential] -name voromqa_sas_potential -value 0");
voronota_set_adjunct_of_atoms("-use [-v! ev28] -name ev28 -value 2");
voronota_set_adjunct_of_atoms("-use [-v! ev56] -name ev56 -value 2");
voronota_set_adjunct_of_atoms("-use [-v! cadscore] -name cadscore -value 1");
voronota_auto_assert_full_success=true;

voronota_set_adjunct_of_atoms_by_expression('-expression', '_linear_combo', '-input-adjuncts', 'cadscore', '-parameters', [-1.0, 1.0], '-output-adjunct', 'ground_truth');

voronota_set_adjunct_of_atoms_by_expression("-use [] -expression _multiply -input-adjuncts voromqa_sas_potential sas_area -output-adjunct voromqa_sas_energy");

voronota_set_adjunct_of_atoms_by_residue_pooling("-source-name voromqa_sas_potential -destination-name residue_mean_sas_potential -pooling-mode mean");
voronota_set_adjunct_of_atoms_by_residue_pooling("-source-name voromqa_sas_potential -destination-name residue_sum_sas_potential -pooling-mode sum");

voronota_set_adjunct_of_atoms("-name tmp_atom_count -value 1");
voronota_set_adjunct_of_atoms_by_residue_pooling("-source-name tmp_atom_count -destination-name residue_size -pooling-mode sum");

voronota_set_adjunct_of_contacts("-use [] -name seq_sep_class -value 5");
voronota_set_adjunct_of_contacts("-use [] -name covalent_bond -value 0");

voronota_run_hbplus('-select-contacts', 'hbonds');
voronota_set_adjunct_of_contacts("-use [hbonds] -name hbond -value 1");

voronota_auto_assert_full_success=false;
voronota_set_adjunct_of_contacts("-use [-min-seq-sep 0 -max-seq-sep 0] -name seq_sep_class -value 0");
voronota_set_adjunct_of_contacts("-use [-min-seq-sep 1 -max-seq-sep 1] -name seq_sep_class -value 1");
voronota_set_adjunct_of_contacts("-use [-min-seq-sep 2 -max-seq-sep 2] -name seq_sep_class -value 2");
voronota_set_adjunct_of_contacts("-use [-min-seq-sep 3 -max-seq-sep 3] -name seq_sep_class -value 3");
voronota_set_adjunct_of_contacts("-use [-min-seq-sep 4 -max-seq-sep 4] -name seq_sep_class -value 4");
voronota_set_adjunct_of_contacts("-use ([-max-seq-sep 0 -max-dist 1.8] or [-min-seq-sep 1 -max-seq-sep 1 -a1 [-aname N] -a2 [-aname C] -max-dist 1.8]) -name covalent_bond -value 1");
voronota_set_adjunct_of_contacts("-use [-v! voromqa_energy] -name voromqa_energy -value 0");
voronota_set_adjunct_of_contacts("-use [-v! hbond] -name hbond -value 0");
voronota_auto_assert_full_success=true;

voronota_unpick_objects();

var modes=['apo', 'holo', 'trajrep'];
var titles=[params.apo_name, params.holo_name, params.trajrep_name];

for(var i=0;i<modes.length;i++)
{
	var mode=modes[i];
	var title=titles[i];
	
	voronota_pick_objects('-names', [mode]);
	
	var file_prefix='./output/graphs/'+mode+'/'+title;
	
	voronota_export_atoms('-as-pdb', '-file', file_prefix+'.pdb', '-pdb-b-factor', 'ground_truth');
	
	voronota_export_adjuncts_of_atoms('-file', file_prefix+'_nodes.csv', '-use', '[]', '-no-serial', '-adjuncts', ['atom_index', 'residue_index', 'atom_type', 'residue_type', 'center_x', 'center_y', 'center_z', 'radius', 'voromqa_sas_potential', 'residue_mean_sas_potential', 'residue_sum_sas_potential', 'residue_size', 'sas_area', 'solvdir_x', 'solvdir_y', 'solvdir_z', 'voromqa_sas_energy', 'voromqa_depth', 'voromqa_score_a', 'voromqa_score_r', 'volume', 'volume_vdw', 'ufsr_a1', 'ufsr_a2', 'ufsr_a3', 'ufsr_b1', 'ufsr_b2', 'ufsr_b3', 'ufsr_c1', 'ufsr_c2', 'ufsr_c3', 'ev28', 'ev56', 'ground_truth'], '-sep', ',', '-expand-ids', true);

	voronota_export_adjuncts_of_contacts('-file', file_prefix+'_links.csv', '-atoms-use', '[]', '-contacts-use', '[-no-solvent]', '-no-serial', '-adjuncts', ['atom_index1', 'atom_index2', 'area', 'boundary', 'distance', 'voromqa_energy', 'seq_sep_class', 'covalent_bond', 'hbond'], '-sep', ',', '-expand-ids', true);
}
EOF
} \
| ../../tools/voronota-js

