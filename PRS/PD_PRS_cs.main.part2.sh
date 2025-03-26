#!/bin/bash
bfile=$1
out=$2
out_final=$3
name=$4
SAMPLE_SIZE=$5



# Loop indefinitely until all files are found
while true; do
  all_files_present=true
  for chr in {1..22};do 
    file=${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt
    if [ ! -f "$file" ]; then
      echo "$file not found, waiting for 15 minutes."
      all_files_present=false
      sleep 15m # Wait for 15 mins
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
    bfile_prefix=$(echo $bfile| sed "s/#/$chr/")
    echo "$bfile_prefix is being calculated"
    # plink2 has a skip dup ID feature. this might be problematic if the multiallelic snps are important. but this is usually QCed.
    #module load nixpkgs/16.09 StdEnv/2020 plink/2.00-10252019-avx2 && plink2 --bfile $bfile_prefix --score ${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt 2 4 6 ignore-dup-ids --out ${out}/${name}.chr${chr}
    command="module load StdEnv/2023 plink/2.00-20231024-avx2 && plink2 --bfile $bfile_prefix --score ${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt 2 4 6 ignore-dup-ids --out ${out}/${name}.chr${chr}"
    sbatch -c 15 --mem=50g -t 0:20:0 --account=def-grouleau --wrap "$command" --out ${out}/${name}.${chr}.score.out
    # --mem=80g for UKB
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
python /lustre03/project/6004655/COMMUN/runs/lang/scripts/PRS/calculate_avg_and_zscore_PRScs_PLINK2.py ${out} ${name} ${out_final}


# how to use
# bash PD_PRS_cs.main.part2.sh "~/scratch/genotype/UKBB_neurohub/PRScs/ukb_chr#" ~/scratch/temp_PRS/PRScs_UKB/ ~/scratch/temp_PRS/PRScs_UKB/ PD 1827641
