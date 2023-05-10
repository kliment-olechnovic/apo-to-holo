# Dataset for training predictors of regions of pocket-related changes in proteins

## Idea

Prepare protein structure-based data suitable for training graph neural networks to predict
what residues in a protein structure are likely to change conformation when pocket opening happens (apo-to-holo transition).
Here, 'apo' means a protein with inactive and possibly completely closed pocket, 'holo' means a protein with an active pocket where a ligand can fit.

## Raw data source

129 apo-holo pairs of protein identifiers were collected from two publications: [CryptoSite](https://pubmed.ncbi.nlm.nih.gov/26854760/) and [PocketMiner](https://pubmed.ncbi.nlm.nih.gov/36859488/).
Every identifier consists of a PDB entry ID and a chain name.

## Downloaded and prepared PDB structures

All pairs of structures were downloaded from [PDB](https://www.rcsb.org) and stripped of all non-protein atoms.
For every pair, a Voronota-JS script was applied to make apo and holo structures have the same sequence and the same residue numbering.
The prepared PDB structures are in [prepare_pairs_of_structures/output/structures/](prepare_pairs_of_structures/output/structures/).

## Generated graphs

