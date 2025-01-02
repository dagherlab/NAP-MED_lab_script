#!/bin/bash
## For PD PRS calculation using PRSice
## only 1800 SNPs in Nalls PD GWAS summary statistics will be used.

# how to use
## bfile_prefix=~/scratch/AMP_PD/chr#
## out=~/scratch/AMP_PD
## name=AMP_PD
## bash PD_PRS.sh $bfile_prefix $out $name

bfile_prefix=$1
out=$2
name=$3

## 1. no pruning in target data
## 2. no clumping in PRSice
## the snp in gwas file is renamed
base=/lustre03/project/6004655/COMMUN/runs/eyu8/data/PRS/PD/UKB/PD_GWAS_2019.PRS.1800.txt
if [ -f $base ];then 
echo "the summary stat file for PD $base is present"
else
echo "please re-specify the path for your PD GWAS summary stat which should be PD_GWAS_2019.PRS.1800.rename.txt"
fi 

# use # to represent the target data is split based on chromosome (only prefix)
# example
## target=CCNA_chr#_rsid_reformat
module load r/4.0.2
target=$bfile_prefix
output_folder=$out
output_name=PD_${name}_PRS
out=${output_folder}/${output_name}
Rscript /lustre03/project/6004655/COMMUN/runs/lang/software/PRSice-2_3_5/PRSice.R \
    --prsice /lustre03/project/6004655/COMMUN/runs/lang/software/PRSice-2_3_5/PRSice_linux \
    --a1 A1 \
    --a2 A2 \
    --bar-levels 1 \
    --base $base \
    --beta  \
    --binary-target T \
    --fastscore  \
    --memory 20gb \
    --no-regress  \
    --num-auto 22 \
    --out $out \
    --print-snp  \
    --pvalue p \
    --score avg \
    --snp SNP \
    --stat b \
    --target $target \
    --thread 10 \
    --ultra \
    --no-clump

#convert tsv to csv
input=${output_folder}/${output_name}
awk 'BEGIN { FS=" "; OFS="," } {$1=$1; print}' ${input}.all_score > ${input}.csv

# convert to zscore 
#PD
module load scipy-stack/2020a python/3.8.10
python /lustre03/project/6004655/COMMUN/runs/lang/scripts/convert_z.py \
    -i ${input}.csv \
    -o ${input}