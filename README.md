# Perturb-seq Reanalysis — Norman et al. 2019

A reanalysis of a CRISPRa Perturb-seq screen in K562 cells, built to practice single-cell analysis and reproduce/extend findings from the source paper.

**Source paper:** Norman et al., *Science* 2019, "Exploring genetic interaction manifolds constructed from rich single-cell phenotypes"
**Data:** [GSE133344](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE133344)
**System:** CRISPRa activation of 105 single genes + combinatorial gene pairs in K562 cells, ~102,000 cells after QC

---

## Loading, QC, and guide parsing

I started from the Cell Ranger–filtered matrices on GEO rather than raw FASTQ, since Cell Ranger doesn't run natively on my machine and the interesting part of this project is Perturb-seq–specific QC, not droplet-calling. After standard filtering (mitochondrial %, total counts, gene counts) and CP10K normalization, 102,337 cells remained. I then parsed the dual-guide CRISPRa identity strings to recover which gene(s) each cell was perturbed with, recovering 105 single-gene targets — matching the count reported in the paper, a good first sanity check that the data was loaded and parsed correctly.

## On-target efficacy

Before trusting any downstream differential expression, I wanted to confirm the CRISPRa system was actually working as expected — i.e., that target genes were reliably being activated.

![On-target efficacy](results/figures/on_target_efficacy.png)
*Target genes show strong, consistent activation (median log2FC ≈ 2.08), confirming the CRISPRa system is working as expected. Note that classical p-values collapse to near-zero for most genes here — a pseudoreplication artifact of testing at the single-cell level with tens of thousands of cells — so I used effect size (log2FC) and penetrance rather than significance to rank genes.*

I also looked at whether activation strength related to how well-represented or how strongly-tagged (guide UMI count) a target was:

![Screen characterization](results/figures/screen_characterization.png)
*Roughly half of cells for a given target don't show detectable activation — "incomplete penetrance" — and this holds across nearly the whole screen, not just weak hits. Log2FC increases with both guide UMI count and cell representation, consistent with a real dosage/efficacy relationship.*

## Differential expression: two methods, cross-validated

I ran DE two ways — a standard single-cell Wilcoxon test, and a pseudobulk approach (aggregating counts per target/lane and running DESeq2) — because the Wilcoxon test's pseudoreplication problem makes its p-values unreliable at this cell count, and I wanted an independent check that wasn't subject to the same issue.

![DE method comparison](results/figures/de_method_comparison.png)
*The two methods agree reasonably well on which genes are significant. Looking at genes with low baseline expression, pseudobulk DE calls them as activated (positive log2FC) almost universally — likely a mix of real biology (a gene switching from off to on mechanically produces a huge fold-change) and statistical noise at low counts. I'd trust the direction of these low-expression hits more than their exact magnitude.*

As a further validation, I checked whether a target's own activation strength predicted how many other genes changed downstream — the paper found these were essentially uncorrelated (R≈0.07), which would be a bit counterintuitive if you assumed "stronger activation → bigger transcriptional effect."

![Fold-activation vs DE gene count](results/figures/fold_activation_vs_de_genes.png)
*[Fill in once you have your R value] — reproducing the paper's finding that activation strength and transcriptional breadth are largely independent.*

## Clustering and cell-state identification

With the perturbation-level analysis in hand, I next asked what cell states exist across the whole screen — since K562 is known to have multi-lineage differentiation potential, and the paper's key biological finding was built around exactly this kind of structure.

![UMAP cluster names](results/figures/UMAP_clusterNames1.png)
*Leiden clustering recovers clear erythroid and myeloid-like differentiation programs, alongside several clusters driven by cell state rather than lineage identity (cell cycle, ribosomal/translation activity, mitochondrial content, interferon response) — a common feature of single-cell data that's worth separating out rather than mislabeling as biological lineages. Cluster identities were assigned using marker genes and Enrichr gene-set enrichment, manually reviewed rather than taken from the single top automated hit — some enrichment results (like a "T cell" marker match in a dataset with no T cells) turned out to be artifacts of shared cell-cycle genes across unrelated marker-gene-set entries, which was a useful reminder not to trust automated annotation blindly.*

## Limitations

- The responder/non-responder split (used to restrict DE to likely-perturbed cells) is a simple expression threshold, not a formal mixture model — a reasonable heuristic, but not a validated classifier.
- Single-cell-level p-values throughout this project are inflated by pseudoreplication; effect sizes and the pseudobulk cross-check are more trustworthy than raw significance.
- Low-expression DE hits should be read for direction, not precise magnitude.

## Next steps

- Genetic interaction modeling on the combinatorial (dual-guide) perturbations, following the paper's additive model to identify synergistic/buffering gene pairs
- Perturbation-level manifold analysis — asking which perturbations enrich which of the cell states identified here, extending the per-cell clustering above into the paper's per-perturbation framing