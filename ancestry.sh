#!/bin/bash

module load gcc
module load r-bundle-bioconductor


FILENAME=$1

### Header should be  FID     IID     FID_IID   Snum    ROUnum  GOnum ###

## No ancestry outliers -> based on Hapmap3 PCA plot, should be near combined CEU/TSI

# downloaded hapmap3 plink format see other script -> hapmap_prep.sh
# NOTE use other script when using NeuroX data
# neuroX_snps_for_hapmap.txt # extract these snps from neuroX
# neuroX_snps_for_hapmap_conversion.txt # conversion of IDs --update-map
# Keep in mind that this comparison with hapmap is based on the number of SNPs that overlap between your input dataset and hapmap

for i in $(seq 1 22); do for j in bed bim fam; do cp ${FILENAME}_chr$i.$j  after_gender_chr$i.$j; done; done

for i in $(seq 1 22); do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_chr$i --snps-only just-acgt --make-bed --out pre_ancestry_chr$i --memory 39000 --threads 9; \
    awk 'BEGIN{FS=OFS="\t"}{$2=$1":"$4; if(snp[$2]>0){$2="DUP"}; snp[$2]=1; print; }' pre_ancestry_chr$i.bim > temp; mv temp pre_ancestry_chr$i.bim; \
    awk '{print $2}' HAPMAP_hg38_new_pos.bim > HAPMAP_hg38_new_pos.snp; \
    plink --bfile pre_ancestry_chr$i --extract HAPMAP_hg38_new_pos.snp --make-bed --out pre_merge_chr$i --memory 39000 --threads 9 &
done
wait

for i in $(seq 1 22); do
    echo "pre_merge_chr$i" >> allchr;
done;

srun -c 10 --mem=40g -t 1:0:0 plink --merge-list allchr --make-bed --out after_gender --memory 39000 --threads 9


srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender --bmerge HAPMAP_hg38_new_pos --out hapmap3_bin_snplis --make-bed --memory 39000 --threads 9; \
plink --bfile after_gender --flip hapmap3_bin_snplis-merge.missnp --make-bed --out after_gender3 --memory 39000 --threads 9; \
plink --bfile after_gender3 --bmerge HAPMAP_hg38_new_pos --out hapmap3_bin_snplis --make-bed --memory 39000 --threads 9; \
plink --bfile after_gender3 --exclude hapmap3_bin_snplis-merge.missnp --out after_gender4 --make-bed --memory 39000 --threads 9; \
plink --bfile after_gender4 --bmerge HAPMAP_hg38_new_pos --out hapmap3_bin_snplis --make-bed --memory 39000 --threads 9

srun -c 10 --mem=40g -t 1:0:0 plink --bfile hapmap3_bin_snplis --geno 0.05 --out pca --make-bed --pca --memory 39000 --threads 9

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

for i in $(seq 1 22); do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_chr$i --keep PCA_filtered_europeans.txt --make-bed --out after_gender_heterozyg_hapmap_chr$i --memory 39000 --threads 9 &
done
wait

cat PCA_filtered_asians.txt PCA_filtered_africans.txt PCA_filtered_mixed_race.txt > hapmap_outliers33.txt
mv hapmap_outliers33.txt log

