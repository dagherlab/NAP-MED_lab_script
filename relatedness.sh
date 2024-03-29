#!/bin/bash

module load gcta
module load gcc
module load r-bundle-bioconductor

data1=$1
data2=$2
eur1=$3
eur2=$4

### Header should be  FID     IID     FID_IID   Snum    ROUnum  GOnum ###
DATABASE_INFO=$5


# this creates several plots and lists based on genetic ancestry

## No relatedness closer than cousin -> Pihat threshold of 0.125
# this is a optional step we usually do it but its upto you
# also can multithread when running in linux or with better version of GCTA --threads ...

for i in $(seq 1 22); do 
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile ${data1}_chr$i --keep $eur1 --make-bed --out data1_chr$i --threads 9 --memory 39000; \
    plink --bfile ${data2}_chr$i --keep $eur2 --make-bed --out data2_chr$i --threads 9 --memory 39000 &
done
wait

rm chr*

for i in $(seq 1 22); do echo -e "data1_chr$i\ndata2_chr$i" >> chr$i; done

for i in $(seq 1 22); do 
    srun -c 10 --mem=40g -t 1:0:0 plink --merge-list chr$i --make-bed --out after_gender_heterozyg_hapmap_chr$i --threads 9 --memory 39000 &
done
wait

for i in $(seq 1 22); do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_heterozyg_hapmap_chr$i --maf 0.05 --geno 0.05 --hwe 1E-6 --make-bed --out filter_chr$i --threads 9 --memory 39000; \
    plink --bfile filter_chr$i --indep-pairwise 50 5 0.5 --out prune_chr$i --threads 9 --memory 39000; \
    plink --bfile filter_chr$i --extract prune_chr$i.prune.in --make-bed --out prune_chr$i --threads 9 --memory 39000 &
done
wait

rm allchr

for i in $(seq 1 22) ; do
    echo "prune_chr$i" >> allchr;
done;

srun -c 10 --mem=40g -t 1:0:0 plink --merge-list allchr --make-bed --out prune --threads 9 --memory 39000; \
gcta64 --bfile prune --make-grm --out GRM_matrix --autosome --maf 0.05 --thread-num 9; \
gcta64 --grm-cutoff 0.125 --grm GRM_matrix --out GRM_matrix_0125 --make-grm; \
gcta64 --grm-singleton 0.125 --grm GRM_matrix --out relatedness_results &

awk '{print $1,$2,$6}' prune.fam > pheno.txt

for i in $(seq 1 22); do
    srun -c 10 --mem=40g -t 1:0:0 plink --bfile after_gender_heterozyg_hapmap_chr$i --keep GRM_matrix_0125.grm.id --make-bed --out after_gender_heterozyg_hapmap_pihat_chr$i --memory 39000 --threads 9 &
done
wait

cut -f 1,2 after_gender_heterozyg_hapmap_chr1.fam > log/IDs_before_relatedness_filter.txt
cut -f 1,2 after_gender_heterozyg_hapmap_pihat_chr1.fam > log/IDs_after_relatedness_filter.txt



