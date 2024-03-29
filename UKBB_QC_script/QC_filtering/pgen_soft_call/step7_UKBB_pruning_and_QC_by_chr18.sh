#!/bin/bash
#SBATCH --time=0-48:00
#SBATCH --account=def-grouleau
#SBATCH --output=step7_UKBB_pruning_and_QC_by_chr18.out
#SBATCH --mem=100g
#SBATCH --cpus-per-task=20
output_folder=/home/liulang/scratch/genotype/UKBB_new_imputation/soft_call/pruning
input_folder=/home/liulang/scratch/genotype/UKBB_new_imputation/soft_call
input_filename=ukb22828_c18_b0_v3
input_file=${input_folder}/${input_filename}
fullpath=${output_folder}/${input_filename}.QC
bash ~/runs/lang/TOMM_TIMM_PRS/script/pruning.sh $input_file $fullpath 
#bash het_check.sh $input_file $fullpath
bash ~/runs/lang/TOMM_TIMM_PRS/script/final_qc.sh $input_file $fullpath

