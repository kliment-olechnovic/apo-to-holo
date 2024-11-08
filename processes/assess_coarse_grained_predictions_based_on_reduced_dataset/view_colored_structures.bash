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
  'spectrum-atoms -adjunct gt -scheme bwr' \
  'spectrum-atoms -adjunct tf -scheme bwr' \
  'multisampling-none' \
  'impostoring-simple' \
  'show-atoms' \
  'grid-by-object' \
  -files

