# Perturb-seq analysis — Norman et al. 2019 (K562, GSE133344)

Small-scope reanalysis: QC, guide/MOI filtering, per-target DE,
and perturbation-similarity analysis on public Perturb-seq data.

# commit 2026-07-13
# download, load in, basic QC, cpm normalization

1. data downloaded

2. cell barcode and CRISPR guide matches provided in filtered_cell_identities. this was generated in parallel to the std CellRanger outs.
We drop the cells that have no guides assigned (later after loading in adata with barcodes to match to this)
We also drop the cells with good_coverage == False, which was a column added by the authors - easy but "blind" filtering in this script

3. checked on barcodes and found that laneID is already appended - serves as unique tag per cell. use as indices
this was likely done by cellranger aggr after indiv CellRanger runs per lane

4. after loading into scanpy, adata.obs is the metadata per cell, with barcode-laneID as index (rownames)
atada.var is metadata per gene. when adata is created, it has no cols, genenames are idnex (rownames)

5. we use sc.pp.calculate_qc_metrics to generate these, which are then populated to both adata.obs and adata.var:
n_genes_by_counts
total_counts
pct_counts_mt

We also did a low-level gene filter (sc.pp.filter_genes(min_cells=3)) to drop genes detected in essentially no cells, before computing QC metrics on the trimmed gene set

# remember to save the raw data layer: adata.layers["counts"] = adata.X.copy()
# before running integrated scanpy norm - sc.pp.normalize_toatal(adata, target_sum=1e4)



