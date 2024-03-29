#!/bin/bash
vcf=$1
## it is located in beluga: ~/runs/lang/script
## this takes vcf files converted from bgen files downloading from UKB-RAP
module load intel/2020.1.217 tabix
name=$(basename $vcf .vcf)
echo $name
echo "step1 extracting snp only vcf $name.snp.only.vcf"
awk 'BEGIN{FS=OFS="\t"}{if($1 ~ /^##/){print $0} else{print $1,$2,$3,$4,$5,$6,$7,$8,$9}}' $vcf > $name.snp.only.vcf
echo "step2 compressing vcf file $name.snp.only.vcf and creating an index file for it > $name.snp.only.vcf.gz"
bgzip -c $name.snp.only.vcf > $name.snp.only.vcf.gz; tabix -p vcf $name.snp.only.vcf.gz;
echo "step3 annotating $name.snp.only.vcf.gz to make it a $name.snp.annotated.vcf"
bcftools annotate -a /lustre02/home/eyu8/runs/eyu8/data/liftOver/dbsnp151_GRCh38p7-All.biallelic.vcf.gz -c ID $name.snp.only.vcf.gz -o $name.snp.annotated.vcf;
echo "step4 add rsid to bim files"
awk 'BEGIN{FS=OFS="\t"}{if(NR==FNR){snp=$1":"$2":"$4":"$5; rs[snp]=$3; next;} snpa=$1":"$4":"$5":"$6; snpb=$1":"$4":"$6":"$5; if(rs[snpa]>0){$2=rs[snpa]} if(rs[snpb]>0){$2=rs[snpb]} print $0}' <(grep -v "^#" ${name}.snp.annotated.vcf | grep rs) ${name}.bim > ${name}_rsid.bim;
cp ${name}.bed ${name}_rsid.bed;
cp ${name}.fam ${name}_rsid.fam;
