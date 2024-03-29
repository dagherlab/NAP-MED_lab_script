#!/bin/bash


# how I prepare the prelift file can be seen in 
##runs/lang/AD_PRS/PRS/data/base/create_liftover_file.ipynb on beluga

#TO CHECK LIST
#1. file is tab-delimited 
#2. the genome build 
#3. a1 is the effect allele
#4. it containS columns CHR, BP, SNP, A1, A2, P, OR/B
#5. Info score > 0.8 and MAF > 0.01 

read gwas output_name output_folder <<< $@

out=${output_folder}/${output_name}
#Remove duplicates
awk '{seen[$3]++; if(seen[$3]==1){ print}}' $gwas > ${out}.nodup
#remove ambiguous
awk '!( ($4=="A" && $5=="T") || \
        ($4=="T" && $5=="A") || \
        ($4=="G" && $5=="C") || \
        ($4=="C" && $5=="G")) {print}' ${out}.nodup > ${out}.QC


