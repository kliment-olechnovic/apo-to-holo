#!/bin/bash

OUTDIR="$1"

if [ -z "$OUTDIR" ] || [ ! -d "${OUTDIR}/atoms_gt" ] || [ ! -d "${OUTDIR}/atoms_pairs" ]
then
	echo "Missing valid directory"
	exit 1
fi

paste \
  <(find "${OUTDIR}/atoms_gt/" -type f -name '*.pa' | sort) \
  <(find "${OUTDIR}/atoms_pairs/" -type f -name '*.pa' | sort) \
| xargs voronota-gl \
  -scripts \
  'spectrum-atoms -adjunct gt -scheme bwr -min-val 0.1 -max-val 0.6' \
  'spectrum-atoms -adjunct tf -scheme bwr -min-val 0.1 -max-val 0.4' \
  'multisampling-none' \
  'impostoring-simple' \
  'show-atoms' \
  'grid-by-object' \
  -files

