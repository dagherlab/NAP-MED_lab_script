#!/bin/bash

file=$1
output=$2


awk '!seen[$1]++' FS="\t" OFS="\t" $file > $output
awk -F"\t" 'seen[$1]++==1' $file | cut -f1 > duplicated_ids.txt

num=$(wc -l duplicated_ids.txt)
echo "there are $num duplicates"