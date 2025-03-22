#!/bin/bash
# how to use
## plink=~/runs/senkkon/2022/TIM_TOM/AMP_PD/chr#_FILTERED
## out=~/scratch/AMP_PD
## bash /lustre03/project/6004655/COMMUN/runs/lang/scripts/PRS/PRS_target_QC.sh $plink $out

# 1. get imputattion > 0.3 (this is up to you, you can apply other cutoff)
# 2. basic qc, maf, hwe, geno, remove dups
# 3. make bed
module load nixpkgs/16.09 plink/2.00a2.3_x86_64
plink=$1 # path/to/your/plinkbychr/files, use # to represent chr number like plink_chr1 -> plink_chr#
out=$2 # dir/to/your/output_files
bychr=${3:-TRUE} # make this FALSE when you are working on a merged plink file

mkdir -p $out 
mkdir -p log
if [ "$bychr" = "FALSE" ]; then
    echo "only one plink file present."
    command="plink2 --bfile $plink --geno 0.01 --maf 0.01 --hwe 1e-6 --out ${out}/chr${chr} --make-bed --rm-dup force-first"
    sbatch -c 10 --mem=60g -t 3:0:0 --account=def-grouleau --wrap "$command" --job-name plink_qc --out log/PRS_plink_QC.out
else
    echo "QC will be performed on files by chr"
    for chr in {1..22};do 
    plinkbychr=$(echo "$plink" | sed "s/#/$chr/")
    command="plink2 --bfile $plinkbychr --geno 0.01 --maf 0.01 --hwe 1e-6 --out ${out}/chr${chr} --make-bed --rm-dup force-first"
    # adjust the resource based on your data
    sbatch -c 10 --mem=20g -t 3:0:0 --account=def-grouleau --wrap "$command" --job-name chr${chr} --out log/chr${chr}.out
    done 
fi



echo "job submitted, check logs in log/"
