#!/bin/bash
#SBATCH --time=0-10:00
#SBATCH --account=def-dagher
#SBATCH --output=step1a_chrX_pre_imputation.out
#SBATCH --mem=160g
#SBATCH --cpus-per-task=20
#SBATCH --mail-user=lang.liu@mail.mcgill.ca
#SBATCH --mail-type=ALL

bash STEP2_pre_imputation_step.sh
