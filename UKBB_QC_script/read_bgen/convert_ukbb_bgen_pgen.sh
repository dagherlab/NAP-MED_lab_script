#!/bin/bash
out=$1
chr=$2
out=${out}/ukb22828_c${chr}_b0_v3
plink2 \
    --bgen /lustre03/project/6008063/neurohub/ukbb/new/Bulk/Imputation/UKB_imputation_from_genotype/ukb22828_c${chr}_b0_v3.bgen \
    --sample /lustre03/project/6008063/neurohub/ukbb/new/Bulk/Imputation/UKB_imputation_from_genotype/ukb22828_c${chr}_b0_v3.sample \
    --make-pgen \
    --out ${out}
