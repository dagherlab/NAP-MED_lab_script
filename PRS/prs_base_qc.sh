#!/bin/bash


#TO CHECK LIST
#1. file is tab-delimited 
#2. the genome build 
#3. a1 is the effect allele
#4. it containS columns CHR, BP, SNP, A1, A2, P, b
#5. Info score > 0.8 and MAF > 0.01 

read gwas output_name output_folder <<< $@
out=${output_folder}/${output_name}

#Remove duplicates $3 is SNP column
awk '{seen[$3]++; if(seen[$3]==1){ print}}' $gwas > ${out}.nodup


