#!/bin/bash

cd "$(dirname $0)"

./prepare_pairs_of_structures/workflow.bash

./generate_graphs/workflow.bash

./generate_coarse_grained_graphs/workflow.bash

./prepare_linear_trajectory_representatives/workflow.bash

./generate_graphs_including_trajectory_data/workflow.bash

./generate_coarse_grained_graphs_including_trajectory_data/workflow.bash

