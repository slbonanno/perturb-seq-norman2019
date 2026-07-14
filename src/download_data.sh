#!/usr/bin/env bash
set -euo pipefail
BASE="https://ftp.ncbi.nlm.nih.gov/geo/series/GSE133nnn/GSE133344/suppl"
OUT="data/raw"
mkdir -p "$OUT"

for f in filtered_matrix.mtx.gz filtered_barcodes.tsv.gz filtered_genes.tsv.gz filtered_cell_identities.csv.gz; do
  echo "downloading $f..."
  curl -L -o "$OUT/GSE133344_${f}" "$BASE/GSE133344_${f}"
done
