#!/bin/bash
module load StdEnv/2020 r/4.0.2

target=$1
snplist=$2
output_folder=$3
cohort=$4
output_name=${output_folder}/${cohort}
mkdir -p $output_folder
Rscript /home/liulang/runs/lang/software/PRSice-2_3_5/PRSice.R \
    --prsice /home/liulang/runs/lang/software/PRSice-2_3_5/PRSice_linux \
    --a1 effect_allele \
    --a2 other_allele \
    --base ~/runs/eyu8/data/Summary_stats/PD_GWAS_summary_stats/PD_GWAS_2019.no23.tsv \
    --beta \
    --bar-levels 1 \
    --exclude $snplist \
    --fastscore \
    --ignore-fid \
    --clump-kb 250kb \
    --print-snp  \
    --clump-p 0.05 \
    --clump-r2 0.100000 \
    --thread 10 \
    --num-auto 22 \
    --out $output_name \
    --no-regress \
    --pvalue p-value \
    --score avg \
    --snp variant_id \
    --stat beta \
    --target $target \
