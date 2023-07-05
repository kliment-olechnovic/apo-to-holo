#!/bin/bash

cd "$(dirname $0)"

if [ -s "./output/graphs_apo.tar.bz2" ]
then
	echo "Presence of file './output/graphs_apo.tar.bz2' indicates that everything is generated and can be extracted with 'tar -xf ./graphs_apo.tar.bz2'"
	exit 0
fi

find ../generate_graphs/output/graphs/apo/ -type f -name '*_nodes.csv' \
| xargs -L 1 -P 8 ./coarse_grain_one_graph.bash ./output/graphs/apo

find ../generate_graphs/output/graphs/holo/ -type f -name '*_nodes.csv' \
| xargs -L 1 -P 8 ./coarse_grain_one_graph.bash ./output/graphs/holo

cd ./output
tar -cjf ./graphs_apo.tar.bz2 ./graphs/apo
tar -cjf ./graphs_holo.tar.bz2 ./graphs/holo
