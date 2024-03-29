#!/bin/bash
bfile=$1
out=$2
out_final=$3
name=$4
SAMPLE_SIZE=$5
keep=${6:-"FALSE"}

# calculate weights for each variant
for chr in {1..22};do 
bfile_prefix=$(echo $bfile| sed "s/\${chr}/${chr}/g")
echo "$bfile_prefix is being calculated"
command="bash /home/liulang/lang/scripts/PRS/PD_PRS_cs.sh $bfile_prefix $out $name $SAMPLE_SIZE $chr"
echo $command
#echo ${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt
#echo ${out_final}/${name}_chr${chr}.out
echo ${out_final}/${name}_chr${chr}.out
sbatch -c 10 --mem=20g -t 4:0:0 --wrap "$command" --account=def-grouleau --out ${out_final}/${name}_chr${chr}.out;
done 

sleep 3h


# Loop indefinitely until all files are found
while true; do
  all_files_present=true
  for chr in {1..22};do 
    file=${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt
    if [ ! -f "$file" ]; then
      echo "$file not found, waiting for 30 minutes."
      all_files_present=false
      sleep 600 # Wait for half an hour
      break # Exit the for loop to start checking from the first file again
    fi
  done

  # If all files are found, run the next program
  if $all_files_present; then
    echo "All files found, running the next program."
    # Command to run the next program goes here
    break # Exit the while loop
  fi
done

# calculate average score for each chromosome and convert to zscore 
# sum up scores across chromosomes and convert to zscore
for chr in {1..22};do 
bfile_prefix=$(echo $bfile| sed "s/\${chr}/${chr}/g")
echo "$bfile_prefix is being calculated"
# plink2 has a skip dup ID feature. this might be problematic if the multiallelic snps are important. but this is usually QCed.
#module load nixpkgs/16.09 StdEnv/2020 plink/2.00-10252019-avx2 && plink2 --bfile $bfile_prefix --score ${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt 2 4 6 ignore-dup-ids --out ${out}/${name}.chr${chr}
command="module load nixpkgs/16.09 StdEnv/2020 plink/2.00-10252019-avx2 && plink2 --bfile $bfile_prefix --score ${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt 2 4 6 ignore-dup-ids --out ${out}/${name}.chr${chr}"
sbatch -c 5 --mem=20g -t 3:0:0 --account=def-grouleau --wrap "$command" --out ${out}/${name}.${chr}.score.out
done 


# check if all the score has bee calculated 
while true; do
  all_files_present=true
  for chr in {1..22};do 
    file=${out}/${name}.chr${chr}.sscore
    if [ ! -f "$file" ]; then
      echo "$file not found, waiting for 30 minutes."
      all_files_present=false
      sleep 600 # Wait for half an hour
      break # Exit the for loop to start checking from the first file again
    fi
  done

  # If all files are found, run the next program
  if $all_files_present; then
    echo "All files found, running the next program."
    # Command to run the next program goes here
    break # Exit the while loop
  fi
done

# calculate the sum and get the zscore

module load scipy-stack/2020a python/3.8.10
python /home/liulang/lang/scripts/PRS/calculate_avg_and_zscore_PRScs_PLINK2.py ${out} ${name} ${out_final}


