# Dataset for training predictors of regions of pocket-related changes in proteins

## Idea

Prepare protein structure-based data suitable for training graph neural networks to predict
what residues in a protein structure are likely to change conformation when pocket opening happens (apo-to-holo transition).
Here, 'apo' means a protein with at least one inactive and partially or completely closed pocket, 'holo' means a protein with at least one pocket where a ligand can fit.

## Raw data source

129 unique apo-holo pairs of protein identifiers were collected from two publications: [CryptoSite](https://pubmed.ncbi.nlm.nih.gov/26854760/) and [PocketMiner](https://pubmed.ncbi.nlm.nih.gov/36859488/).
Every identifier consists of a __PDB entry ID__ and a __chain name__.
Identifiers for all the pairs are listed in the [table](processes/prepare_pairs_of_structures/output/candidate_pairs.txt).

## Downloaded and prepared PDB structures

All pairs of structures were downloaded from [PDB](https://www.rcsb.org) and stripped of all non-protein atoms.
For every pair, the Voronota-JS-based [script](processes/prepare_pairs_of_structures/prepare_pair_of_structures.bash) was applied to make apo and holo structures have the same sequence and the same residue numbering.
The prepared PDB structures are in [processes/prepare_pairs_of_structures/output/structures](processes/prepare_pairs_of_structures/output/structures).

## Ground truth definition

For every apo-holo pair, both apo and holo structures were processed with the Voronota-JS-based [script](processes/generate_graphs/generate_graphs_for_pair_of_structures.bash).
The side chains were rebuilt with [FASPR](https://pubmed.ncbi.nlm.nih.gov/32259206/).
The apo and holo structures were compared using CAD-score - from local per-residue CAD-score values, the residue structural difference scores were derived.
These difference scores, ranging from 0 to 1, are __the ground truth__ intended to be predicted via machine learning.
Below are all the apo structures colored by ground truth (using blue-white-red color gradient for values from 0 to 1):

![processes/generate_graphs/output/view_grid_apo_small.jpg](processes/generate_graphs/output/view_grid_apo_small.jpg)

A similar picture for holo structures is [also available](processes/generate_graphs/output/view_grid_holo_small.jpg).

## Generated graphs

A graph was generated for every structure in the aforementioned Voronota-JS-based [script](processes/generate_graphs/generate_graphs_for_pair_of_structures.bash).
In a graph, nodes are atoms and atom-atom contacts are links.
Contacts were derived from the Voronoi tessellation of atomic balls.
Various features (mostly tessellation-derived) were assigned to nodes and links.
Ground truth values were assigned to nodes.

For a graph, there are three generated files:

* `"{PDB ID}_{chain ID}_nodes.csv"` - graph nodes table file, one row per node
* `"{PDB ID}_{chain ID}_links.csv"` - graph links table file, one row per link
* `"{PDB ID}_{chain ID}.pdb"` - graph source structure PDB file with ground truth values written as b-factors

All the generated apo graphs are in the compressed archive [processes/generate_graphs/output/graphs_apo.tar.bz2](processes/generate_graphs/output/graphs_apo.tar.bz2).
It can be extracted with the following command: `tar -xf graphs_apo.tar.bz2`.

### Data format of the graph nodes file

Example (first 10 lines) from the file `"processes/generate_graphs/output/graphs/apo/1ALB_A_nodes.csv"`:

    ID_chainID,ID_resSeq,ID_iCode,ID_serial,ID_altLoc,ID_resName,ID_name,atom_index,residue_index,atom_type,residue_type,center_x,center_y,center_z,radius,sas_area,solvdir_x,solvdir_y,solvdir_z,voromqa_sas_energy,voromqa_depth,voromqa_score_a,voromqa_score_r,volume,volume_vdw,ufsr_a1,ufsr_a2,ufsr_a3,ufsr_b1,ufsr_b2,ufsr_b3,ufsr_c1,ufsr_c2,ufsr_c3,ground_truth
    A,1,.,.,.,CYS,N,0,0,33,4,-4.888,-4.117,-12.419,1.7,1.50572,-0.702918,0.0626468,-0.708507,2.91049,1,0.519699,0.526727,47.4673,14.961,19.2054,59.986,3.9078,23.1923,77.6654,-209.263,24.3315,77.5231,-241.817,0.19469
    A,1,.,.,.,CYS,CA,1,0,31,4,-3.675,-4.612,-13.021,1.9,0,0,0,0,0,2,0.710737,0.526727,24.5866,13.1057,19.2054,59.986,3.9078,23.1923,77.6654,-209.263,24.3315,77.5231,-241.817,0.19469
    A,1,.,.,.,CYS,C,2,0,30,4,-3.167,-3.753,-14.168,1.75,0,0,0,0,0,2,0.546854,0.526727,12.4852,8.77074,19.2054,59.986,3.9078,23.1923,77.6654,-209.263,24.3315,77.5231,-241.817,0.19469
    A,1,.,.,.,CYS,O,3,0,34,4,-2.727,-2.696,-13.746,1.49,0,0,0,0,0,2,0.742626,0.526727,14.6754,8.7862,19.2054,59.986,3.9078,23.1923,77.6654,-209.263,24.3315,77.5231,-241.817,0.19469
    A,1,.,.,.,CYS,CB,4,0,32,4,-3.874,-6.041,-13.53,1.91,18.25,-0.498282,-0.464353,-0.732183,17.5875,1,0.167824,0.526727,74.7288,18.0972,19.2054,59.986,3.9078,23.1923,77.6654,-209.263,24.3315,77.5231,-241.817,0.19469
    A,1,.,.,.,CYS,SG,5,0,35,4,-4.181,-7.251,-12.224,1.88,14.5498,-0.362334,-0.74476,-0.560398,15.2449,1,0.472624,0.526727,95.1056,23.18,19.2054,59.986,3.9078,23.1923,77.6654,-209.263,24.3315,77.5231,-241.817,0.19469
    A,2,.,.,.,ASP,N,6,1,27,3,-3.184,-3.885,-15.501,1.7,3.82055,-0.920977,-0.19033,-0.339965,4.84824,1,0.764478,0.529847,29.2849,10.2192,20.9096,68.1799,-32.7315,23.1923,77.6654,-209.263,24.3315,77.5231,-241.817,0.0730536
    A,2,.,.,.,ASP,CA,7,1,24,3,-2.432,-2.946,-16.337,1.9,0,0,0,0,0,2,0.823961,0.529847,17.4446,12.8244,20.9096,68.1799,-32.7315,23.1923,77.6654,-209.263,24.3315,77.5231,-241.817,0.0730536
    A,2,.,.,.,ASP,C,8,1,23,3,-2.725,-1.433,-16.302,1.75,0,0,0,0,0,2,0.739412,0.529847,11.1895,8.50682,20.9096,68.1799,-32.7315,23.1923,77.6654,-209.263,24.3315,77.5231,-241.817,0.0730536

Description of the graph nodes table columns:

* __ID_chainID__ - chain name in PDB file, given just for reference
* __ID_resSeq__ - residue number in PDB file, given just for reference
* __ID_iCode__ - insertion code in PDB file, usually null and written as '.', given just for reference
* __ID_altLoc__ - atom alternate location indicator in PDB file, usually null and written as '.', given just for reference
* __ID_serial__ - atom serial number in PDB file, usually null and written as '.', given just for reference
* __ID_resName__ - residue name
* __ID_name__ - atom name
* __atom_index__ - atom index (starting from 0), used to describe atom-atom links in the corresponding links.csv file
* __residue_index__ - residue index (starting from 0), to be used for pooling (from atom-level to residue-level)
* __atom_type__ - atom type encoded as a number from 0 to 159
* __residue_type__ - amino acid residue type encoded as a number from 0 to 19
* __center_x__, __center_y__, __center_z__ - atom center coordinates, to be either ignored or used with special care ensuring rotational and translational invariance
* __radius__ - atom van der Waals radius
* __sas_area__ - solvent-accessible surface area: larger area means that the atom is less buried and more exposed
* __solvdir_x__, __solvdir_y__, __solvdir_z__ - mean solvent-accessible surface direction vector, to be either ignored or used with special care ensuring rotational and translational invariance
* __voromqa_sas_energy__ - observed atom-solvent VoroMQA energy value
* __voromqa_depth__ - atom topological distance from the surface, starts with 1 for surface atoms
* __voromqa_score_a__ - atom-level VoroMQA score
* __voromqa_score_r__ - residue-level VoroMQA score, same for all the  atoms in the same residue
* __volume__ - volume of the Voronoi cell of an atom constrained inside the solvent-accessible surface
* __volume_vdw__ - volume of the Voronoi cell of an atom constrained inside the van der Waals surface
* __ufsr_a1__, __ufsr_a2__, ... , __ufsr_c2__, __ufsr_c3__ - geometric descriptors calculated using the Ultra-fast Shape Recognition algorithm adapted for polymers
* __ground_truth__ - residue-level ground truth value to be predicted, same for all the  atoms in the same residue, equals to 1 - (residue CAD-score)

### Data format of the graph links file

Example (first 10 lines) from the file `"processes/generate_graphs/output/graphs/apo/1ALB_A_links.csv"`:

    ID1_chainID,ID1_resSeq,ID1_iCode,ID1_serial,ID1_altLoc,ID1_resName,ID1_name,ID2_chainID,ID2_resSeq,ID2_iCode,ID2_serial,ID2_altLoc,ID2_resName,ID2_name,atom_index1,atom_index2,area,boundary,distance,voromqa_energy,seq_sep_class,covalent_bond,hbond
    A,1,.,.,.,CYS,N,A,1,.,.,.,CYS,CA,0,1,11.6331,0,1.4418,0,0,1,0
    A,1,.,.,.,CYS,N,A,1,.,.,.,CYS,C,0,2,3.1235,0,2.48059,0,0,0,0
    A,1,.,.,.,CYS,N,A,1,.,.,.,CYS,O,0,3,0.758293,0,2.9069,0,0,0,0
    A,1,.,.,.,CYS,N,A,1,.,.,.,CYS,CB,0,4,7.4393,0.654979,2.44219,0,0,0,0
    A,1,.,.,.,CYS,N,A,1,.,.,.,CYS,SG,0,5,5.43818,0,3.21867,0,0,0,0
    A,1,.,.,.,CYS,N,A,2,.,.,.,ASP,N,0,6,2.68301,1.13217,3.52933,0,1,0,0
    A,1,.,.,.,CYS,N,A,3,.,.,.,ALA,N,0,14,1.8631,0.173318,4.74373,2.65026,2,0,0
    A,1,.,.,.,CYS,N,A,3,.,.,.,ALA,CB,0,18,4.42907,1.10056,5.61697,2.52179,2,0,0
    A,1,.,.,.,CYS,N,A,4,.,.,.,PHE,CD1,0,25,7.07321,0,3.6361,3.01638,3,0,0

Description of the graph links table columns:

* __ID1_chainID__, __ID1_resSeq__, __ID1_iCode__, __ID1_serial__, __ID1_altLoc__, __ID1_resName__, __ID1_name__ -  general info about the first atom participating in the link, see descriptions of ID columns of the nodes table
* __ID2_chainID__, __ID2_resSeq__, __ID2_iCode__, __ID2_serial__, __ID2_altLoc__, __ID2_resName__, __ID2_name__ -  general info about the second atom participating in the link, see descriptions of ID columns of the nodes table
* __atom_index1__ - node index of the first atom participating in the link
* __atom_index2__ - node index of the second atom participating in the link
* __area__ - tessellation-derived contact area
* __boundary__ - length of the contact-solvent boundary, 0 if contact is not adjacent to the solvent-accessible surface
* __distance__ - distance between two atoms
* __voromqa_energy__ - contact VoroMQA-energy value
* __seq_sep_class__ - residue sequence separation class, ranging from 0 (sequence separation = 0) to 5 (sequence separation >= 5)
* __covalent_bond__ - covalent bond indicator (0 or 1)
* __hbond__ - hydrogen bond indicator (0 or 1)

## Important notes

### About graph connectivity

The links in the links.csv file are to be viewed as non-directional.
For processing with a GNN, it is usually necessary to define bidirectional connections and self-connections:

* if there is (i -> j) link, there should also be (j -> i) link with the same features
* there should be (i -> i) link with apppropriate features for every node i

### About self-link features

Here are suggestions for assigning feature values for the self-link of atom i, i.e. (i -> i) link:

* self __area__ = sum of the __area__ values of (i -> j) links for all neighboring atoms j
* self __boundary__ = sum of the __boundary__ values of (i -> j) links for all neighboring atoms j
* self __distance__ = 0
* self __voromqa_energy__ = sum of the __voromqa_energy__ values of (i -> j) links for all neighboring atoms j
* self __seq_sep_class__ = 0
* self __covalent_bond__ - 0
* self __hbond__ - 0

It may be a good idea to add an additional indicator attribute to every link, e.g.:

* __is_self__ - self-link indicator (0 for a normal link, 1 for a self-link)

### About atom-to-residue pooling

An atom-level graph can be coarse-grained - converted into a residue-level graph.
A residue-level graph is much smaller, therefore much faster to train GNNs with.
The area, volume, and energy features can be simply summed when going to the residue level.

### About normalization of node and link feature values

It is adviseable, that most of the node and link feature values should be normalized universally (not on per-graph basis, but based on some global statistics) -
for example, converted to z-scores using mean and standard deviation values known beforehand or derived from all the graphs used in training:

    z_score = (x - mean) / standard_deviation

### About choice between regression and classification

Both regression and classification training can be implemented using the provided data.

In case of classification, the threshold for the ground truth values can be set to 0.5, or (better) be determined by looking at the histogram of the ground truth values.

In my opinion, classifiers are easier to train and assess, but good regressors are more useful in practice.

### About the data imbalace

This data is very imbalanced - residues with conformational changes through the apo-to-holo transition are very much in minority.
One way to handle the imbalanced is to configure (or modify) the loss function to use weights derived from the distribution of ground truth values.

### About using the data in PyTorch Geometric

I made a separate [repository](https://github.com/kliment-olechnovic/gnn-custom-dataset-example)
that is intended purely to demonstrate how to make a graph dataset for PyTorch Geometric from graph nodes (vertices) and links (edges) stored in CSV files.

