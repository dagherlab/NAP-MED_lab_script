#!/bin/bash
module load StdEnv/2020 r/4.0.2
target=$1
bed=$2
output_folder=$3
cohort=$4
output_name=${output_folder}/${cohort}.AD
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
bed=$(echo $result|sed 's/,$//')


Rscript ~/runs/lang/software/PRSice-2_3_5/PRSice.R \
    --prsice ~/runs/lang/software/PRSice-2_3_5/PRSice_linux \
    --a1 effect_allele \
    --a2 other_allele \
    --base /lustre03/project/6004655/COMMUN/runs/go_lab/summary_stats/AD/GCST90027158_buildGRCh38.PRS.tsv.gz \
    --no-regress \
    --beta \
    --bar-levels 1 \
    --fastscore \
    --ignore-fid \
    --clump-kb 250kb \
    --print-snp  \
    --clump-p 0.05 \
    --clump-r2 0.100000 \
    --bed ${bed} \
    --thread 10 \
    --perm 10000 \
    --num-auto 22 \
    --out $output_name \
    --pvalue p_value \
    --score avg \
    --snp variant_id \
    --stat beta \
    --target $target \


# reformat
awk 'BEGIN { FS=" "; OFS="," } {$1=$1; print}' $output_name.all_score  > $output_name.csv
# convert to zscore
module load scipy-stack/2020a python/3.8.10
python /lustre03/project/6004655/COMMUN/runs/lang/scripts/convert_z.py \
    -i $output_name.csv \
    -o ${output_folder}