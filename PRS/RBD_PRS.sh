#!/bin/bash
## For PD PRS calculation using PRSice
## only 1800 SNPs in Nalls PD GWAS summary statistics will be used.
bfile_prefix=$1
out=$2
name=$3
keep=${4:-"FALSE"}

## optimal pvalue is 1e-4, found by Chia in the paper
## the snp in gwas file is renamed
base=/home/liulang/scratch/GWAS/RBD/META_GWAS_2020_PRS.QC.tab.QC
if [ -f $base ];then 
echo "the summary stat file for RBD $base is present"
else
echo "please re-specify the path for your RBD GWAS summary stat"
fi 

# use # to represent the target data is split based on chromosome (only prefix)
# example
## target=CCNA_chr#_rsid_reformat
module load r/4.0.2
target=$bfile_prefix
output_folder=$out
output_name=RBD_${name}_PRS
out=${output_folder}/${output_name}
if [ "$keep" = "FALSE" ]; then
Rscript /home/liulang/runs/lang/software/PRSice-2_3_5/PRSice.R \
    --prsice /home/liulang/runs/lang/software/PRSice-2_3_5/PRSice_linux \
    --a1 A1 \
    --a2 A2 \
    --no-full \
    --bar-levels 1e-5 \
    --base $base \
    --beta  \
    --fastscore \
    --print-snp  \
    --no-default \
    --clump-kb 250kb \
    --clump-p 1.000000 \
    --clump-r2 0.100000 \
    --no-regress  \
    --num-auto 22 \
    --out $out \
    --pvalue P \
    --score avg \
    --snp SNP \
    --stat b \
    --target $target \
    --thread 10 \
    --ultra   
else
Rscript /home/liulang/runs/lang/software/PRSice-2_3_5/PRSice.R \
    --prsice /home/liulang/runs/lang/software/PRSice-2_3_5/PRSice_linux \
    --a1 A1 \
    --a2 A2 \
    --no-full \
    --bar-levels 1e-5 \
    --base $base \
    --beta  \
    --fastscore \
    --print-snp  \
    --clump-kb 250kb \
    --clump-p 1.000000 \
    --clump-r2 0.100000 \
    --no-default \
    --no-regress  \
    --num-auto 22 \
    --out $out \
    --pvalue P \
    --score avg \
    --snp SNP \
    --stat b \
    --target $target \
    --thread 10 \
    --ultra  \
    --keep $keep 
fi 
#convert tsv to csv
input=${output_folder}/${output_name}
awk 'BEGIN { FS=" "; OFS="," } {$1=$1; print}' ${input}.all_score > ${input}.csv

# convert to zscore 
#PD
module load scipy-stack/2020a python/3.8.10
python /lustre03/project/6004655/COMMUN/runs/lang/scripts/convert_z.py \
    -i ${input}.csv \
    -o ${input}