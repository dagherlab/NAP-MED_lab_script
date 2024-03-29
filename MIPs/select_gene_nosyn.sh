#!/bin/bash

output=$1

awk -v gene_name=$2 'BEGIN{FS=OFS="\t"}{
  if (FNR==1) {
    print
    for (i=1; i<=NF; i++) {
      if ($i ~ /Gene symbol (Gene)/) gene = i;
      if ($i ~ /Variant function type (VFT)/) var = i;
    }
    next;
  };
  if ($gene ~ gene_name){
    if($var ~ /stop/ || $var ~ /nonsyn/ || $var ~ /frame/ || $var ~ /intronic_splicing/){
        print
    }
  }
}' $output
