#!/bin/bash
### actual imputation code PD for on biowulf
## part 2
## BEFORE RUNNING REPLACE "$YOURFILE" WITH THE NAME OF YOUR PLINK FILE

# forward strand

# Previously I used their script -> http://www.well.ox.ac.uk/~wrayner/tools/  -> http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim.v4.2.5.zip  
# Usage with HRC reference panel:
# Requires the unzipped tab delimited HRC reference (currently v1.1 HRC.r1-1.GRCh37.wgs.mac5.sites.tab) from the Haplotype Reference Consortium Website here:
# http://www.haplotype-reference-consortium.org/site
# Usage: perl HRC-1000G-check-bim-v4.2.pl -b <bim file> -f <Frequency file> -r <Reference panel> -h
# Use at least 40g of memory

module load intel/2020.1.217
module load vcftools
module load tabix

cp ../data_here/FILTERED* .
plink --bfile FILTERED --freq --out FILTERED

perl HRC-1000G-check-bim.pl -b FILTERED.bim -f FILTERED.frq -r PASS.Variants.BRAVO_TOPMed_Freeze_8_hg19.tab.gz -h

## clean up data see log file of perl HRC-1000G-check-bim.pl using PLINK see also the generated "Run-plink.sh" file
## Does -> --update-map --flip  --reference-allele

# log file keep! LOG-after_gender_heterozyg_pihat_hapmap_mind_missing12-HRC.txt

sh Run-plink.sh

## plink to vcf per chromosome

for chnum in {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23};
  do
  plink --bfile FILTERED-updated-chr$chnum --recode vcf --chr $chnum --out FILTERED-$chnum &
done

wait
## vcfsort and zip


for chnum in {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23};
  do
	vcf-sort FILTERED-$chnum.vcf | bgzip -c >  pre_impute_FILTERED_$chnum.vcf.gz &
done

wait
## make sure all variants pass the checkVCF utility for input
# from website http://genome.sph.umich.edu/wiki/CheckVCF.py
# python checkVCF.py -r hs37d5.fa -o test $your_VCF   

for chnum in {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23};
  do
	python CheckVCF.py -r hs37d5.fa -o FILTERED_test_$chnum pre_impute_FILTERED_$chnum.vcf.gz &
done

wait
cat FILTERED_test_*check.log > log_file_check_vcf.FILTERED.txt



## note no MAF or HWE filters this time around

