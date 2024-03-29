#!/bin/bash

NAME=$1
i=$2


module load StdEnv/2020 intel/2020.1.217 tabix bcftools/1.11
echo "start annotating"

zcat raw/chr$i.dose.vcf.gz | awk 'BEGIN{FS=OFS="\t"}{if($1 ~ /^##/){print $0} else{print $1,$2,$3,$4,$5,$6,$7,$8,$9}}' > raw/chr$i.snp.only.vcf

bgzip -c raw/chr$i.snp.only.vcf > raw/chr$i.snp.only.vcf.gz; tabix -p vcf raw/chr$i.snp.only.vcf.gz;
bcftools annotate --rename-chrs ~/runs/lang/scripts/chr_name_conv.txt raw/chr${i}.snp.only.vcf.gz | bgzip > raw/chr${i}.snp.only.rename.vcf.gz
mv raw/chr${i}.snp.only.rename.vcf.gz raw/chr${i}.snp.only.vcf.gz;
tabix -p vcf raw/chr${i}.snp.only.vcf.gz;
echo "done with step2"

##### MIGHT BE STUCK AT THIS STEP BUT IT IS NOT A BUG
bcftools annotate -a /lustre02/home/eyu8/runs/eyu8/data/liftOver/dbsnp151_GRCh38p7-All.biallelic.vcf.gz -c ID raw/chr$i.snp.only.vcf.gz -o raw/chr$i.snp.annotated.vcf;

echo "start reformatting rsids"


awk 'BEGIN{FS=OFS="\t"}{if(NR==FNR){snp=$1":"$2":"$4":"$5; rs[snp]=$3; next;} snpa=$1":"$4":"$5":"$6; snpb=$1":"$4":"$6":"$5; if(rs[snpa]>0){$2=rs[snpa]} if(rs[snpb]>0){$2=rs[snpb]} print $0}' <(grep -v "^#" raw/chr$i.snp.annotated.vcf | grep rs) hard_calls/${NAME}_chr$i.bim > hard_calls/${NAME}_chr${i}_rsid_reformat.bim

cp hard_calls/${NAME}_chr$i.bed hard_calls/${NAME}_chr${i}_rsid_reformat.bed
cp hard_calls/${NAME}_chr$i.fam hard_calls/${NAME}_chr${i}_rsid_reformat.fam

awk 'BEGIN{FS=OFS="\t"}{if(NR==FNR){snp=$1":"$2":"$4":"$5; rs[snp]=$3; next;} snpa=$1":"$4":"$5":"$6; snpb=$1":"$4":"$6":"$5; if(rs[snpa]>0){$2=rs[snpa]} if(rs[snpb]>0){$2=rs[snpb]} print $0}' <(grep -v "^#" raw/chr$i.snp.annotated.vcf | grep rs) soft_calls/${NAME}_chr$i.bim > soft_calls/${NAME}_chr${i}_rsid_reformat.bim

cp soft_calls/${NAME}_chr$i.bed soft_calls/${NAME}_chr${i}_rsid_reformat.bed
cp soft_calls/${NAME}_chr$i.fam soft_calls/${NAME}_chr${i}_rsid_reformat.fam
echo "done"
