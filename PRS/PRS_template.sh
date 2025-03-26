#!/bin/bash

bfile_prefix=$1 # plink file prefix, they will serve as the target data
# example
## bfile_prefix=CCNA_chr#_rsid_reformat if your plink files are by chr, use # for chr 
out=$2 # out dir
name=$3 # file name

## optimal pvalue is 1e-4, found by Chia in the paper
## the snp in gwas file is renamed
base=/path/to/your/gwas/summary_stat
if [ -f $base ];then 
echo "the summary stat file is present"
else
echo "please re-specify the path for your GWAS summary stat"
fi 

# use # to represent the target data is split based on chromosome (only prefix)
# --no-default to force PRSice not looking at CHR and BP columns because they are not matched (GRCh37 and GRCh38)

module load r/4.0.2
target=$bfile_prefix
output_folder=$out
output_name=DLB_${name}_PRS
out=${output_folder}/${output_name}
Rscript /home/liulang/runs/lang/software/PRSice-2_3_5/PRSice.R \
    --prsice /home/liulang/runs/lang/software/PRSice-2_3_5/PRSice_linux \
    --a1 A1 \ # column name
    --a2 A2 \ # column name
    --no-full \
    --bar-levels 1e-4 \ # you can compare multiple different pvalue thresholds here by doing 1e-4,1e-5,5e-8. we usually use the optimal p value threshold
    --base $base \
    --no-default \
    --or  \ # change to --beta if you are using beta as the effect size
    --fastscore \
    --print-snp  \
    --clump-kb 250kb \
    --clump-p 1.000000 \
    --clump-r2 0.100000 \
    --no-regress  \
    --num-auto 22 \
    --out $out \
    --pvalue P \ # column name
    --score avg \
    --snp SNP \ # column name
    --stat OR \ # column name
    --target $target \
    --thread 10 \
    --ultra  

#convert tsv to csv (this may fail. because they may name the extension .best or .all_score )
input=${output_folder}/${output_name}
awk 'BEGIN { FS=" "; OFS="," } {$1=$1; print}' ${input}.all_score > ${input}.csv

# convert to zscore 
#PD
module load scipy-stack/2020a python/3.8.10
python /lustre03/project/6004655/COMMUN/runs/lang/scripts/convert_z.py \
    -i ${input}.csv \
    -o ${input}