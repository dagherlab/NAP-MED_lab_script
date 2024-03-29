#!/bin/bash
#SBATCH --time=0-3:00
#SBATCH --account=def-grouleau
#SBATCH --output=step6_UKBB_soft_call_pgen_by_chr1.out
#SBATCH --mem=100g
#SBATCH --cpus-per-task=40
pfile=/home/liulang/scratch/genotype/UKBB_new_imputation/ukb22828_c1_b0_v3
out=/home/liulang/scratch/genotype/UKBB_new_imputation/soft_call/ukb22828_c1_b0_v3
extract=/home/liulang/scratch/genotype/UKBB_new_imputation/soft_call/ukb22828_c1_b0_v3_soft.snplist
bash /home/liulang/runs/lang/scripts/UKBB_QC_script/QC_filtering/pgen_soft_call/soft_call_pgen.sh $pfile $extract $out

