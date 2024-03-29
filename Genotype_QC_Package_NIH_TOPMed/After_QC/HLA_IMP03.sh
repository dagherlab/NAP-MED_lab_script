#!/bin/bash

module load plink
plink --bfile FILTERED-updated-chr6 --chr 6 --from-mb 20 --to-mb 40 --recode vcf --out myHLAregionData
module load intel/2018.3
module load vcftools
module load tabix
vcf-sort myHLAregionData.vcf | bgzip -c > HLA_IMP03.vcf.gz
