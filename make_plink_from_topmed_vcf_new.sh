#!/bin/bash

# how to use
## transfer this file to the folder where there is a raw folder containing all imputation files from topmed. makes ure the zip files have been decompressed
# NAME=IPDGC
# for chr in {1..22} X;do 
# command="bash /home/liulang/lang/scripts/make_plink_from_topmed_vcf_new.sh $NAME $chr"
# sbatch -c 3 --mem=30g -t 5:0:0 --account=def-grouleau --wrap "$command" --out chr$chr.out
# done

# to split the SNP column
# awk '{
#   if ($2 ~ /^rs[0-9]+$/) {
#     print;
#   } else {
#     split($2, a, ":");
#     if (a[1] ~ /^rs[0-9]+$/) {
#       $2 = a[1];
#     } else {
#       $2 = a[3]":"a[4];
#     }
#     print;
#   }
# }' bim > rsid.bim

NAME=$1
chr=$2

mkdir -p soft_calls
mkdir -p hard_calls
module load StdEnv/2020 intel/2020.1.217 tabix
gunzip raw/chr$chr.info.gz
#convert them to chr:bp:a1:a2 for missing rsid. convert to rsid:a1:a2 if it has rsid
zcat raw/chr$chr.dose.vcf.gz | awk -F'\t' 'BEGIN{OFS="\t"} /^#/ {print; next} {if($3 == ".") $3 = $1":"$2":"$4":"$5; else $3 = $3":"$4":"$5; print}' > raw/chr$chr.dose.temp.vcf;
#corresponding info file also need to reformatted.
awk -F'\t' 'BEGIN{OFS="\t"} /^#/ {print; next} {if($3 == ".") $3 = $1":"$2":"$4":"$5; else $3 = $3":"$4":"$5; print}' raw/chr${chr}.info > raw/chr${chr}.info.temp


#move R2 to QUAL column
awk -F'\t' 'BEGIN{OFS="\t"} 
    !/^#/ {
        split($8, infoFields, ";");
        for(i in infoFields) {
            if(infoFields[i] ~ /^R2=/) {
                r2Value = substr(infoFields[i], 4);
                $6 = r2Value;
                break;
            }
        }
        print;
    } 
    /^#/ {print}' raw/chr${chr}.info.temp > raw/chr${chr}.info.temp2
module load StdEnv/2020 plink/1.9b_6.21-x86_64
plink --vcf raw/chr$chr.dose.temp.vcf --make-bed --out s1_chr$chr --const-fid;
plink --bfile s1_chr$chr --bmerge s1_chr$chr --merge-mode 6 --out s8_chr$chr;
plink --bfile s1_chr$chr --exclude s8_chr$chr.diff --make-bed --out s2_chr$chr;
plink --bfile s2_chr$chr --list-duplicate-vars --out s4_chr$chr;
plink --bfile s2_chr$chr --exclude s4_chr$chr.dupvar --make-bed --out softcalls_chr$chr;
plink --bfile softcalls_chr$chr --qual-scores raw/chr${chr}.info.temp2 6 3 '#' --qual-threshold 0.8 --make-bed --out hard_calls/${NAME}_chr$chr
plink --bfile softcalls_chr$chr --qual-scores raw/chr${chr}.info.temp2 6 3 '#' --qual-threshold 0.3 --make-bed --out soft_calls/${NAME}_chr$chr

rm s?_chr$chr*
rm softcalls_chr$chr*
rm raw/chr$chr.dose.temp.vcf
rm raw/chr${chr}.info.temp

