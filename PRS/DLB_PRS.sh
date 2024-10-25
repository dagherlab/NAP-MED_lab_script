#!/bin/bash
## For PD PRS calculation using PRSice
## only 1800 SNPs in Nalls PD GWAS summary statistics will be used.
bfile_prefix=$1
out=$2
name=$3
keep=${4:-"FALSE"}

## optimal pvalue is 1e-4, found by Chia in the paper
## the snp in gwas file is renamed
base=/home/liulang/scratch/GWAS/DLB/Chia_R/GCST90001390_buildGRCh38_PRS.QC.nomissing.tsv
if [ -f $base ];then 
echo "the summary stat file for PD $base is present"
else
echo "please re-specify the path for your PD GWAS summary stat which should be PD_GWAS_2019.PRS.1800.rename.txt"
fi 

# use # to represent the target data is split based on chromosome (only prefix)
# --no-default to force PRSice not looking at CHR and BP columns because they are not matched (GRCh37 and GRCh38)
# example
## target=CCNA_chr#_rsid_reformat
module load r/4.0.2
target=$bfile_prefix
output_folder=$out
output_name=DLB_${name}_PRS
out=${output_folder}/${output_name}
if [ "$keep" = "FALSE" ]; then
Rscript /home/liulang/runs/lang/software/PRSice-2_3_5/PRSice.R \
    --prsice /home/liulang/runs/lang/software/PRSice-2_3_5/PRSice_linux \
    --a1 A1 \
    --a2 A2 \
    --no-full \
    --bar-levels 1e-4 \
    --base $base \
    --no-default \
    --or  \
    --fastscore \
    --print-snp  \
    --clump-kb 250kb \
    --clump-p 1.000000 \
    --clump-r2 0.100000 \
    --no-regress  \
    --num-auto 22 \
    --out $out \
    --pvalue P \
    --score avg \
    --snp SNP \
    --stat OR \
    --target $target \
    --thread 10 \
    --ultra  
else
Rscript /home/liulang/runs/lang/software/PRSice-2_3_5/PRSice.R \
    --prsice /home/liulang/runs/lang/software/PRSice-2_3_5/PRSice_linux \
    --a1 A1 \
    --a2 A2 \
    --no-full \
    --bar-levels 1e-4 \
    --base $base \
    --or  \
    --no-default \
    --fastscore \
    --print-snp  \
    --clump-kb 250kb \
    --clump-p 1.000000 \
    --clump-r2 0.100000 \
    --no-regress  \
    --num-auto 22 \
    --keep $keep \
    --out $out \
    --pvalue P \
    --score avg \
    --snp SNP \
    --stat OR \
    --target $target \
    --thread 10 \
    --ultra 
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