#!/bin/bash
pfile=$1;
extract=$2;
out=$3
module load StdEnv/2020 plink/2.00-10252019-avx2;
plink2 \
    --pfile $pfile \
    --extract $extract \
    --make-bed \
    --out $out
