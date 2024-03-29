#!/bin/bash

NAME=$1
chr=$2

eval mkdir soft_calls
eval mkdir hard_calls

gunzip raw/chr$chr.info.gz
plink --vcf raw/chr$chr.dose.vcf.gz --make-bed --out s1_chr$chr --const-fid
plink --bfile s1_chr$chr --bmerge s1_chr$chr --merge-mode 6 --out s8_chr$chr
plink --bfile s1_chr$chr --exclude s8_chr$chr.diff --make-bed --out s2_chr$chr
plink --bfile s2_chr$chr --list-duplicate-vars --out s4_chr$chr
plink --bfile s2_chr$chr --exclude s4_chr$chr.dupvar --make-bed --out softcalls_chr$chr
plink --bfile softcalls_chr$chr --qual-scores raw/chr$chr.info 7 1 1 --qual-threshold 0.8 --make-bed --out hard_calls/${NAME}_chr$chr
plink --bfile softcalls_chr$chr --qual-scores raw/chr$chr.info 7 1 1 --qual-threshold 0.3 --make-bed --out soft_calls/${NAME}_chr$chr

rm s?_chr$chr*
rm softcalls_chr$chr*

