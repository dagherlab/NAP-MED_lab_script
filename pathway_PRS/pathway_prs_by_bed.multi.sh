#!/bin/bash
module load StdEnv/2020 r/4.0.2
target=$1
bed=$2
output_folder=$3
cohort=$4
output_name=${output_folder}/${cohort}
mkdir -p $output_folder

if [[ "$cohort" == "UKB" ]]; then
    ext=.GRCh37.bed
else 
    ext=.GRCh38.bed
fi 

# reformat bed variable from path/name1.GRCh37.bed,path/name2.GRCh37.bed.... to path/name1.GRCh37.bed:name1,path/name2.GRCh37.bed:name2....
result=""
# Process each entry separated by a comma
IFS=',' read -ra files <<< "$bed"
for file in "${files[@]}"; do
  # Extract the basename without the path and extension
  base=$(basename "$file" $ext)
  # Append to result in the desired format
  result+="$file:$base,"
done
bed=$result 


Rscript ~/runs/lang/software/PRSice-2_3_5/PRSice.R \
    --prsice ~/runs/lang/software/PRSice-2_3_5/PRSice_linux \
    --a1 effect_allele \
    --a2 other_allele \
    --base ~/runs/eyu8/data/Summary_stats/PD_GWAS_summary_stats/PD_GWAS_2019.no23.tsv \
    --beta \
    --bar-levels 1 \
    --fastscore \
    --ignore-fid \
    --binary-target T \
    --clump-kb 250kb \
    --print-snp  \
    --clump-p 0.05 \
    --clump-r2 0.100000 \
    --bed ${bed} \
    --thread 10 \
    --perm 10000 \
    --prevalence 0.005 \
    --num-auto 22 \
    --cov $covariate \
    --pheno $pheno \
    --pheno-col phenotype \
    --out $output_name \
    --pvalue p-value \
    --score avg \
    --snp variant_id \
    --stat beta \
    --target $target \
