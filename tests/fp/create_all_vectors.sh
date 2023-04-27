#!/bin/sh

mkdir -p vectors
./create_vectors.sh
./remove_spaces.sh

# to create tvs for evaluation of combined IFdivsqrt
./combined_IF_vectors/extract_testfloat_vectors.py
./combined_IF_vectors/extract_arch_vectors.py