#!/bin/bash
#SBATCH --time=0-6:00
#SBATCH --account=def-grouleau
#SBATCH --output=step0_make_bim_files.out
#SBATCH --mem=200g
#SBATCH --cpus-per-task=40
#SBATCH --mail-user=lang.liu@mail.mcgill.ca
#SBATCH --mail-type=ALL
module load nixpkgs/16.09 plink/2.00a2.3_x86_64
for chr in $(seq 1 11);do
    plink2 \
        --bgen /project/rpp-aevans-ab/neurohub/ukbb/genetics/imp/ukb_imp_chr${chr}_v3.bgen \
        --sample /project/rpp-aevans-ab/neurohub/ukbb/genetics/imp/ukb45551_imp_chr${chr}_v3_s487296.sample \
        --make-bed \
        --out /lustre04/scratch/liulang/genotype/UKBB/ukb_imp_chr${chr}_v3
done

