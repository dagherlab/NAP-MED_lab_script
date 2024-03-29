#!/bin/bash

FILENAME=$1
THREADS=$2

### Actual cleaning pre-imputation code 
### start like this sh STEP1_pre_imputation_step.sh FILENAME
## part 1 of 2 
## part to is written in STEP2_pre_imputation_step.sh
## Cornelis
## Last update August 3 2018
## Run using plink 1.9 and on HG19

### Sample cleaning inclusion:

# NOTE did you already filter for gentrain scores??
# if not perhaps you want to do that....

# NOTE do all samples have a gender??
# if not those samples that do not have a gender will be removed

# NOTE do all your samples have an affection status??
# if not this will cause trouble at the end of this script

## Genotyping call rates per sample
# open file call_rates.imiss and F_MISS - 1 = callrate
# all call rates saved in CALL_RATES_ALL_SAMPLES.txt

module load gcta

# this creates several plots and lists based on genetic ancestry

## No relatedness closer than cousin -> Pihat threshold of 0.125 
# this is a optional step we usually do it but its upto you
# also can multithread when running in linux or with better version of GCTA --threads ...

gcta64 --bfile after_gender_heterozyg_hapmap --make-grm --out GRM_matrix --autosome --maf 0.05 --thread-num $THREADS
gcta64 --grm-cutoff 0.125 --grm GRM_matrix --out GRM_matrix_0125 --make-grm
awk '{print $1,$2,$6}' after_gender_heterozyg_hapmap.fam > pheno.txt
plink --bfile after_gender_heterozyg_hapmap --keep GRM_matrix_0125.grm.id --make-bed --out after_gender_heterozyg_hapmap_pihat



cut -f 1,2 after_gender_heterozyg_hapmap.fam > log/IDs_before_relatedness_filter.txt
cut -f 1,2 after_gender_heterozyg_hapmap_pihat.fam > log/IDs_after_relatedness_filter.txt

## No missingness per variant geno 0.05
# high call rate (95% for GWAS, 90% for NeuroX on exome background)

plink --bfile after_gender_heterozyg_hapmap_pihat --pheno pheno.txt --make-bed --out after_gender_heterozyg_pihat_mind --geno 0.05
grep "(--geno)" after_gender_heterozyg_pihat_mind.log > log/MISSINGNESS_SNPS.txt


### Variant inclusion criteria:
# missingness by case control P > 1E-4 # needs case control status

plink --bfile after_gender_heterozyg_pihat_mind --test-missing --out missing_snps 
awk '{if ($5 <= 0.0001) print $2 }' missing_snps.missing > missing_snps_1E4.txt
plink --bfile after_gender_heterozyg_pihat_mind --exclude missing_snps_1E4.txt --make-bed --out after_gender_heterozyg_pihat_mind_missing1
sort -u missing_snps_1E4.txt > log/VARIANT_TEST_MISSING_SNPS.txt


# missing by haplotype P > 1E-4

plink --bfile after_gender_heterozyg_pihat_mind_missing1 --test-mishap --out missing_hap 
awk '{if ($8 <= 0.0001) print $9 }' missing_hap.missing.hap > missing_haps_1E4.txt
sed 's/|/\
/g' missing_haps_1E4.txt > missing_haps_1E4_final.txt

sort -u missing_haps_1E4_final.txt > log/HAPLOTYPE_TEST_MISSING_SNPS.txt
plink --bfile after_gender_heterozyg_pihat_mind_missing1 --exclude missing_haps_1E4_final.txt --make-bed --out after_gender_heterozyg_pihat_hapmap_mind_missing12

# Optional hardy Weinberg SNP from controls

plink --bfile after_gender_heterozyg_pihat_hapmap_mind_missing12 --filter-controls --hwe 1E-4 --write-snplist
plink --bfile after_gender_heterozyg_pihat_hapmap_mind_missing12 --extract plink.snplist --make-bed --out after_gender_heterozyg_pihat_hapmap_mind_missing123

mv after_gender_heterozyg_pihat_hapmap_mind_missing123.bim data_here/FILTERED.bim
mv after_gender_heterozyg_pihat_hapmap_mind_missing123.bed data_here/FILTERED.bed
mv after_gender_heterozyg_pihat_hapmap_mind_missing123.fam data_here/FILTERED.fam

####### REMOVE A LOT TO CLEAN FOLDER...

rm pheno.txt
rm hapmap3_bin_snplis.bed
rm hapmap3_bin_snplis.bim
rm hapmap3_bin_snplis.fam
rm hapmap3_bin_snplis.log
rm hapmap3_bin_snplis.hh
rm after_gender4.bed
rm after_gender4.bim
rm after_gender4.fam
rm after_gender4.hh
rm after_gender4.log
rm hapmap3_bin_snplis-merge.missnp
rm after_gender3.bed
rm after_gender3.bim
rm after_gender3.fam
rm after_gender3.hh
rm after_gender3.log
rm after_gender.bed
rm after_gender.bim
rm after_gender.fam
rm after_gender.hh
rm after_gender.log
rm after_gender.nosex
rm afri.txt
rm asia.txt
rm eur.txt
rm pca.bed
rm pca.bim
rm pca.fam
rm pca.log
rm pca.eigenval
rm afrio.txt
rm asiao.txt
rm euro.txt
rm new_samples_add.txt
rm new_samples.txt
rm new_samples2.txt
rm after_gender_heterozyg_pihat_mind.hh
rm after_gender_heterozyg_hapmap_pihat.bed
rm after_gender_heterozyg_hapmap_pihat.bim
rm after_gender_heterozyg_hapmap_pihat.fam
rm GRM_matrix_0125.grm.id
rm GRM_matrix.grm.id
rm after_gender_heterozyg_hapmap.bim
rm after_gender_heterozyg_hapmap.log
rm after_gender_heterozyg_pihat_mind_missing1.bed
rm after_gender_heterozyg_pihat_mind_missing1.fam
rm after_gender_heterozyg_pihat_mind_missing1.hh
rm missing_snps_1E4.txt
rm after_gender_heterozyg_pihat_mind.bed
rm after_gender_heterozyg_pihat_mind.bim
rm after_gender_heterozyg_pihat_mind.fam
rm after_gender_heterozyg_pihat_mind.log
rm missing_snps.hh
rm missing_snps.log
rm missing_snps.missing
rm missing_haps_1E4_final.txt
rm missing_haps_1E4.txt
rm after_gender_heterozyg_pihat_mind_missing1.bim
rm after_gender_heterozyg_pihat_mind_missing1.log
rm missing_hap.hh
rm missing_hap.log
rm missing_hap.missing.hap
rm after_gender_heterozyg_hapmap.bed
rm after_gender_heterozyg_hapmap.fam
rm after_gender_heterozyg_hapmap.hh
rm plink.snplist
rm *.hh
rm after_gender_heterozyg_pihat_hapmap_mind_missing12.bed
rm after_gender_heterozyg_pihat_hapmap_mind_missing12.bim
rm after_gender_heterozyg_pihat_hapmap_mind_missing12.fam
rm after_gender_heterozyg_pihat_hapmap_mind_missing12.log



