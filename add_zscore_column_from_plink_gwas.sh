#!/bin/bash

out=${1}.temp

# Calculate mean and standard deviation of the 10th column
mean=$(awk -F'\t' 'NR>1 {sum+=$10} END {print sum/(NR-1)}' $1)
std_dev=$(awk -F'\t' -v mean="$mean" 'NR>1 {sum+=($10-mean)^2} END {print sqrt(sum/(NR-1))}' $1)

# Output the original data with the z-score as an additional column
awk -F'\t' -v mean="$mean" -v std_dev="$std_dev" 'BEGIN {OFS="\t"} NR==1 {print $0, "Z"} NR>1 {print $0, ($10-mean)/std_dev}' $1 > $out
