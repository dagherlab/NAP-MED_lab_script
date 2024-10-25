#!/bin/bash
# how to use
# bash /lustre03/project/6004655/COMMUN/runs/lang/scripts/segregation_analysis_bygene/get_genotypes_by_bed_and_fam.sh /lustre03/project/6004655/COMMUN/runs/rambani1/HSP_exomes/analysis/joint-calling/HSP_exomes.vcf.gz path/to/bed
VCF_FILE=$1
BED_FILE=$2
# FAM_FILE=$3
echo "make sure you run this script in a screen"
# Extract sample IDs from the FAM file (assuming the sample IDs are in the first column)
# SAMPLE_IDS=$(cut -f1 $FAM_FILE | paste -sd "," -)

mkdir -p ~/scratch/tmp/
module load StdEnv/2023 gcc/12.3 bcftools/1.19
# Use bcftools to filter the VCF file based on the BED file and sample IDs from the FAM file
# srun -c 5 --mem=10g -t 3:0:0 --account=def-grouleau bcftools view -R $BED_FILE -s $SAMPLE_IDS $VCF_FILE -o ~/scratch/tmp/HSP.subset.vcf
srun -c 5 --mem=10g -t 0:20:0 --account=def-grouleau bcftools view -R $BED_FILE $VCF_FILE -o ~/scratch/tmp/HSP.subset.vcf

module load StdEnv/2023 plink/2.00-20231024-avx2
# --output-chr M for recoding 23 to X
srun -c 1 --mem=5g -t 0:10:0 --account=def-grouleau plink --vcf ~/scratch/tmp/HSP.subset.vcf --make-bed --out ~/scratch/tmp/HSP.subset --output-chr M


srun -c 1 --mem=5g -t 0:10:0 --account=def-grouleau plink --bfile ~/scratch/tmp/HSP.subset --recode --out ~/scratch/tmp/HSP.subset
