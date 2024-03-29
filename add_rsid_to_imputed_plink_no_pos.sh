#!/bin/bash

NAME=$1
i=$2

module load intel/2020.1.217 tabix

echo "start reformatting rsids"


awk 'BEGIN{FS=OFS="\t"}{if(NR==FNR){snp=$1":"$2":"$4":"$5; rs[snp]=$3; next;} snpa=$1":"$4":"$5":"$6; snpb=$1":"$4":"$6":"$5; if(rs[snpa]>0){$2=rs[snpa]} if(rs[snpb]>0){$2=rs[snpb]} print $0}' <(grep -v "^#" raw/chr$i.snp.annotated.vcf | grep rs) hard_calls/${NAME}_chr$i.bim > hard_calls/${NAME}_chr${i}_rsid_reformat.bim

cp hard_calls/${NAME}_chr$i.bed hard_calls/${NAME}_chr${i}_rsid_reformat.bed
cp hard_calls/${NAME}_chr$i.fam hard_calls/${NAME}_chr${i}_rsid_reformat.fam

awk 'BEGIN{FS=OFS="\t"}{if(NR==FNR){snp=$1":"$2":"$4":"$5; rs[snp]=$3; next;} snpa=$1":"$4":"$5":"$6; snpb=$1":"$4":"$6":"$5; if(rs[snpa]>0){$2=rs[snpa]} if(rs[snpb]>0){$2=rs[snpb]} print $0}' <(grep -v "^#" raw/chr$i.snp.annotated.vcf | grep rs) soft_calls/${NAME}_chr$i.bim > soft_calls/${NAME}_chr${i}_rsid_reformat.bim

cp soft_calls/${NAME}_chr$i.bed soft_calls/${NAME}_chr${i}_rsid_reformat.bed
cp soft_calls/${NAME}_chr$i.fam soft_calls/${NAME}_chr${i}_rsid_reformat.fam
echo "done"
