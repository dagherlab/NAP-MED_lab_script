#!/bin/bash

FILENAME=$1

### Sample cleaning inclusion:

# Make sure the filenames are correct

# NOTE do all samples have a gender??
# if not those samples that do not have a gender will be removed

# NOTE do all your samples have an affection status??
# if not this will cause trouble at the end of this script

## Genotyping call rates per sample
# open file call_rates.imiss and F_MISS - 1 = callrate
# all call rates saved in CALL_RATES_ALL_SAMPLES.txt

module load gcta/1.26.0
module load gcc
module load r-bundle-bioconductor

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile ${FILENAME}.chr$i --missing --out call_rates_chr$i --memory 39000 --threads 9 &
done;
wait

for i in $(seq 1 22) X; do
    awk '{if ($5 == 1) print $2 }' call_rates_chr$i.lmiss > snp_outliers_chr$i.txt
done

## No heterozygosity outliers  
# --het from LD pruned data > use F cut-off of -0.15 and <- 0.15 for inclusion
# outliers stored here -> all_outliers.txt
# all heterozygosity is stored here -> HETEROZYGOSITY_DATA.txt

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile ${FILENAME}.chr$i --geno 0.01 --maf 0.05 --indep-pairwise 50 5 0.5 --out pruning_chr$i; plink --bfile ${FILENAME}.chr$i --extract pruning_chr$i.prune.in --make-bed --out pruned_data_chr$i &
done;
wait

for i in $(seq 1 22) X; do
    echo "pruned_data_chr$i" >> allchr;
done;

sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="plink --merge-list allchr --het --out prunedHet --memory 39000 --threads 9"

awk '{if ($6 <= -0.15) print $0 }' prunedHet.het > outliers1.txt
awk '{if ($6 >= 0.15) print $0 }' prunedHet.het > outliers2.txt
cat outliers1.txt outliers2.txt > HETEROZYGOSITY_OUTLIERS.txt

cut -f 1,2 HETEROZYGOSITY_OUTLIERS.txt > all_outliers.txt

mv prunedHet.het HETEROZYGOSITY_DATA.txt

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile ${FILENAME}.chr$i --remove all_outliers.txt --exclude snp_outliers_chr$i.txt --make-bed --out after_heterozyg_chr$i &
done
wait

mv HETEROZYGOSITY_DATA.txt log

rm prun*
rm outlier*
rm all_outliers.txt

## No call rate outliers for samples
# all call rates outliers are in CALL_RATE_OUTLIERS.txt
# the samples in your chr might differ, make sure that the samples stay consistent

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_heterozyg_chr$i --mind 0.05 --make-bed --out after_heterozyg_call_rate_chr$i &
done
wait

## No sex check fails -> check with original sample sheet 
# (Note for neuroX data that does not have GWAS back bone, use F cut-off of 0.50 instead of 0.25/0.75 and only use the PAR region’s common variants always)
# PAR = --chr 23 --from-bp 2699520 --to-bp 154931043 --maf 0.05 --geno 0.05 --hwe 1E-5 
# gender failures are stored in GENDER_FAILURES.txt
# gender checks are stored in GENDER_CHECK1.txt and GENDER_CHECK2.txt

sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="plink --bfile after_heterozyg_call_rate_chrX --check-sex 0.25 0.75 --maf 0.05 --out gender_check1 --memory 39000 --threads 9"
sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="plink --bfile after_heterozyg_call_rate_chrX --chr 23 --from-bp 2781479 --to-bp 155701383 --maf 0.05 --geno 0.05 --hwe 1E-5 --check-sex  0.25 0.75 --out gender_check2 --memory 39000 --threads 9"

touch samples_to_remove.txt
grep "PROBLEM" gender_check1.sexcheck > problems1.txt
grep "PROBLEM" gender_check2.sexcheck > problems2.txt
cat problems1.txt problems2.txt > GENDER_FAILURES.txt

cut -f 1,2 GENDER_FAILURES.txt > samples_to_remove.txt

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_heterozyg_call_rate_chr$i --remove samples_to_remove.txt --make-bed --out after_gender_chr$i --memory 39000 --threads 9 &
done
wait

rm gender_check*
rm after_heterozyg_call_rate*

mv gender_check1.sexcheck GENDER_CHECK1.txt
mv gender_check2.sexcheck GENDER_CHECK2.txt

mv GENDER_FAILURES.txt log

## No ancestry outliers -> based on Hapmap3 PCA plot, should be near combined CEU/TSI

# downloaded hapmap3 plink format see other script -> hapmap_prep.sh
# NOTE use other script when using NeuroX data
# neuroX_snps_for_hapmap.txt # extract these snps from neuroX
# neuroX_snps_for_hapmap_conversion.txt # conversion of IDs --update-map
# Keep in mind that this comparison with hapmap is based on the number of SNPs that overlap between your input dataset and hapmap

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_chr$i --snps-only just-acgt --make-bed --out pre_ancestry_chr$i --memory 39000 --threads 9 &
done
wait

for i in $(seq 1 22) X; do
    awk 'BEGIN{FS=OFS="\t"}{if(NR==FNR){snp[$2]=1; next;} id=$1":"$4; if(snp[id]>0){$2=id;} print}' HAPMAP_hg38_new_pos.bim pre_ancestry_chr$i.bim > a; awk 'BEGIN{FS=OFS="\t"}{if(snp[$2]>0){$2="DUP"} snp[$2]=1; print; }' a > pre_ancestry_chr$i.bim
done

awk '{print $2}' HAPMAP_hg38_new_pos.bim > HAPMAP_hg38_new_pos.snp

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile pre_ancestry_chr$i --extract HAPMAP_hg38_new_pos.snp --make-bed --out pre_merge_chr$i --memory 39000 --threads 9 &
done
wait

rm allchr

for i in $(seq 1 22) ; do
    echo "pre_merge_chr$i" >> allchr;
done;

sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="plink --merge-list allchr --make-bed --out after_gender --memory 39000 --threads 9"


sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="plink --bfile after_gender --bmerge HAPMAP_hg38_new_pos --out hapmap3_bin_snplis --make-bed --memory 39000 --threads 9"

sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="plink --bfile after_gender --flip hapmap3_bin_snplis-merge.missnp --make-bed --out after_gender3 --memory 39000 --threads 9"

sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="plink --bfile after_gender3 --bmerge HAPMAP_hg19_new_pos --out hapmap3_bin_snplis --make-bed --memory 39000 --threads 9"

sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="plink --bfile after_gender3 --exclude hapmap3_bin_snplis-merge.missnp --out after_gender4 --make-bed --memory 39000 --threads 9"

sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="plink --bfile after_gender4 --bmerge HAPMAP_hg38_new_pos --out hapmap3_bin_snplis --make-bed --memory 39000 --threads 9"

sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="plink --bfile hapmap3_bin_snplis --geno 0.05 --out pca --make-bed --pca --memory 39000 --threads 9"


grep "EUROPE" pca.eigenvec > eur.txt
grep "ASIA" pca.eigenvec > asia.txt
grep "AFRICA" pca.eigenvec > afri.txt
grep -v -f eur.txt pca.eigenvec | grep -v -f asia.txt | grep -v -f afri.txt > new_samples.txt
cut -d " " -f 3 after_gender_chr1.fam > new_samples_add.txt
paste new_samples_add.txt new_samples.txt > new_samples2.txt
paste eur_add.txt eur.txt > euro.txt
paste asia_add.txt asia.txt > asiao.txt
paste afri_add.txt afri.txt > afrio.txt

cat new_samples2.txt euro.txt asiao.txt afrio.txt > pca.eigenvec2

# R script for PCA plotting and filtering
R < PCA_in_R.R --no-save

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_chr$i --keep PCA_filtered_europeans.txt --make-bed --out after_gender_heterozyg_hapmap_chr$i --memory 39000 --threads 9 &
done
wait

cat PCA_filtered_asians.txt PCA_filtered_africans.txt PCA_filtered_mixed_race.txt > hapmap_outliers33.txt
mv hapmap_outliers33.txt log


# this creates several plots and lists based on genetic ancestry

## No relatedness closer than cousin -> Pihat threshold of 0.125 
# this is a optional step we usually do it but its upto you
# also can multithread when running in linux or with better version of GCTA --threads ...

for i in $(seq 1 22); do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_heterozyg_hapmap_chr$i --maf 0.05 --geno 0.05 --hwe 1E-6 --make-bed --out filter_chr$i --threads 9 --memory 39000; plink --bfile filter_chr$i --indep-pairwise 50 5 0.5 --out prune_chr$i --threads 9 --memory 39000; plink --bfile filter_chr$i --extract prune_chr$i.prune.in --make-bed --out prune_chr$i --threads 9 --memory 39000 &
done
wait

rm allchr

for i in $(seq 1 22) ; do
    echo "prune_chr$i" >> allchr;
done;

sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="plink --merge-list allchr --make-bed --out prune --threads 9 --memory 39000"

sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="gcta64 --bfile prune --make-grm --out GRM_matrix --autosome --maf 0.05 --thread-num 9"
sbatch -W -c 10 --mem=40g -t 1:0:0 --wrap="gcta64 --grm-cutoff 0.125 --grm GRM_matrix --out GRM_matrix_0125 --make-grm"

awk '{print $1,$2,$6}' prune.fam > pheno.txt

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_heterozyg_hapmap_chr$i --keep GRM_matrix_0125.grm.id --make-bed --out after_gender_heterozyg_hapmap_pihat_chr$i --memory 39000 --threads 9 &
done
wait

cut -f 1,2 after_gender_heterozyg_hapmap.fam > log/IDs_before_relatedness_filter.txt
cut -f 1,2 after_gender_heterozyg_hapmap_pihat.fam > log/IDs_after_relatedness_filter.txt

## No missingness per variant geno 0.05
# high call rate (95% for GWAS, 90% for NeuroX on exome background)

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_heterozyg_hapmap_pihat_chr$i --pheno pheno.txt --make-bed --out after_gender_heterozyg_pihat_mind_chr$i --geno 0.05 --memory 39000 --threads 9 &
done
wait

### Variant inclusion criteria:
# missingness by case control P > 1E-4 # needs case control status

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_heterozyg_pihat_mind_chr$i --test-missing --out missing_snps_chr$i --memory 39000 --threads 9 &
done
wait

for i in $(seq 1 22) X; do
    awk '{if ($5 <= 0.0001) print $2 }' missing_snps_chr$i.missing > missing_snps_1E4_chr$i.txt
done

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_heterozyg_pihat_mind_chr$i --exclude missing_snps_1E4_chr$i.txt --make-bed --out after_gender_heterozyg_pihat_mind_missing1_chr$i --memory 39000 --threads 9 &
done
wait


# missing by haplotype P > 1E-4

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_heterozyg_pihat_mind_missing1_chr$i --test-mishap --out missing_hap_chr$i --memory 39000 --threads 9 &
done
wait

for i in $(seq 1 22) X; do
    awk '{if ($8 <= 0.0001) print $9 }' missing_hap_chr$i.missing.hap > missing_haps_1E4_chr$i.txt;
    sed 's/|/\
    /g' missing_haps_1E4_chr$i.txt > missing_haps_1E4_final_chr$i.txt
done

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_heterozyg_pihat_mind_missing1_chr$i --exclude missing_haps_1E4_final_chr$i.txt --make-bed --out after_gender_heterozyg_pihat_hapmap_mind_missing12_chr$i --memory 39000 --threads 9 &
done
wait

# Optional hardy Weinberg SNP from controls

for i in $(seq 1 22) X; do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_heterozyg_pihat_hapmap_mind_missing12_chr$i --filter-controls --hwe 1E-4 --write-snplist --out hwe_chr$i --memory 39000 --threads 9; plink --bfile after_gender_heterozyg_pihat_hapmap_mind_missing12_chr$i --extract hwe_chr$i.snplist --make-bed --out after_gender_heterozyg_pihat_hapmap_mind_missing123_chr$i --memory 39000 --threads 9 &
done
wait

for i in $(seq 1 22) X; do
    mv after_gender_heterozyg_pihat_hapmap_mind_missing123_chr$i.bim data_here/FILTERED_chr$i.bim;
    mv after_gender_heterozyg_pihat_hapmap_mind_missing123_chr$i.bed data_here/FILTERED_chr$i.bed;
    mv after_gender_heterozyg_pihat_hapmap_mind_missing123_chr$i.fam data_here/FILTERED_chr$i.fam;
done
