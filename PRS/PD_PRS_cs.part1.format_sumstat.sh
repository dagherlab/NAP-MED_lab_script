#!/bin/bash
sumstat=/lustre03/project/6004655/COMMUN/runs/go_lab/summary_stats/PD_2025/GP2_euro_ancestry_meta_analysis_2024/GP2_ALL_EUR_ALL_DATASET_HG38_12162024.rsid.txt.gz
out=~/scratch/GWAS/PD/PD_GWAS_2025.tab.PRScs

# change $2, $5, $6, $8, $9 to your column number to match "SNP", "A1", "A2", "BETA", "SE"
zcat $sumstat | awk -F'\t' -v OFS='\t' 'NR==1 {print "SNP", "A1", "A2", "BETA", "SE"} NR>1 {print $2, $5, $6, $8, $9}' > $out.temp1
# remove duplicate snps, 0 se and non-numerical SE
awk '{ if ( $5 != "" || $5 != 0 || $5 ~ /^[+-]?[0-9]+([.][0-9]+)?$/) print }' $out.temp1 > $out

rm $out.temp1

