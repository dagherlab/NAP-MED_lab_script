#!/bin/bash
sumstat=/home/liulang/runs/eyu8/data/Summary_stats/PD_GWAS_summary_stats/PD_GWAS_2019.no23.tsv
out=~/scratch/GWAS/PD/PD_GWAS_2019.no23.tab.PRScs

awk -F'\t' -v OFS='\t' 'NR==1 {print "SNP", "A1", "A2", "BETA", "SE"} NR>1 {print $1, $4, $5, $7, $8}' $sumstat > $out


