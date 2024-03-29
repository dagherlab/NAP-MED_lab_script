
#!/bin/bash

NAME=$1
i=$2

module load intel/2020.1.217 tabix
#uncomment here if you think your vcf file looks good (chr notation is purely number)
#chr_name_conv.txt is a file with chr${i} ${i} on each line for all chr

echo "step1: start getting snp only file"
zcat raw/chr$i.dose.vcf.gz | awk 'BEGIN{FS=OFS="\t"}{if($1 ~ /^##/){print $0} else{print $1,$2,$3,$4,$5,$6,$7,$8,$9}}' > raw/chr$i.snp.only.vcf
echo "done with step 1"
echo "step2: transform chrX to X (optional)"

bgzip -c raw/chr$i.snp.only.vcf > raw/chr$i.snp.only.vcf.gz; tabix -p vcf raw/chr$i.snp.only.vcf.gz;
bcftools annotate --rename-chrs ~/runs/lang/scripts/chr_name_conv.txt raw/chr${i}.snp.only.vcf.gz | bgzip > raw/chr${i}.snp.only.rename.vcf.gz
mv raw/chr${i}.snp.only.rename.vcf.gz raw/chr${i}.snp.only.vcf.gz;
tabix -p vcf raw/chr${i}.snp.only.vcf.gz;
echo "done with step2"

echo "step3: start adding rs id"
#uncomment this when you don't transform chromosome number above
#bgzip -c raw/chr$i.snp.only.vcf > raw/chr$i.snp.only.vcf.gz; tabix -p vcf raw/chr$i.snp.only.vcf.gz;

bcftools annotate -a /lustre02/home/eyu8/runs/eyu8/data/liftOver/dbsnp151_GRCh38p7-All.biallelic.vcf.gz -c ID raw/chr$i.snp.only.vcf.gz -o raw/chr$i.snp.annotated.vcf;
echo "done with step3"
echo "step4: start add rsid to soft calls andhard calls"
awk 'BEGIN{FS=OFS="\t"}{if(NR==FNR){snp=$1":"$2":"$4":"$5; rs[snp]=$3":"$4":"$5; next;} snpa=$1":"$4":"$5":"$6; snpb=$1":"$4":"$6":"$5; if(rs[snpa]>0){$2=rs[snpa]} if(rs[snpb]>0){$2=rs[snpb]} print $0}' <(grep -v "^#" raw/chr$i.snp.annotated.vcf | grep rs) hard_calls/${NAME}_chr$i.bim > hard_calls/${NAME}_chr${i}_rsid.bim

cp hard_calls/${NAME}_chr$i.bed hard_calls/${NAME}_chr${i}_rsid.bed
cp hard_calls/${NAME}_chr$i.fam hard_calls/${NAME}_chr${i}_rsid.fam

awk 'BEGIN{FS=OFS="\t"}{if(NR==FNR){snp=$1":"$2":"$4":"$5; rs[snp]=$3":"$4":"$5; next;} snpa=$1":"$4":"$5":"$6; snpb=$1":"$4":"$6":"$5; if(rs[snpa]>0){$2=rs[snpa]} if(rs[snpb]>0){$2=rs[snpb]} print $0}' <(grep -v "^#" raw/chr$i.snp.annotated.vcf | grep rs) soft_calls/${NAME}_chr$i.bim > soft_calls/${NAME}_chr${i}_rsid.bim

cp soft_calls/${NAME}_chr$i.bed soft_calls/${NAME}_chr${i}_rsid.bed
cp soft_calls/${NAME}_chr$i.fam soft_calls/${NAME}_chr${i}_rsid.fam
echo "done with step4"
