#!/bin/bash
#SBATCH --time=0-3:00
#SBATCH --account=def-grouleau
#SBATCH --output=step2_convert_ukbb_bgen_pgen_by_chr19.out
#SBATCH --mem=100g
#SBATCH --cpus-per-task=40
out=~/scratch/genotype/UKBB_new_imputation/
bash /home/liulang/runs/lang/scripts/UKBB_QC_script/convert_ukbb_bgen_pgen.sh $out 19

