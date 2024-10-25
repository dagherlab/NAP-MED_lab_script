#!/bin/bash
# bfile: prefix for plink files (chr need to be specified with ${chr})
# out_final: final directory for scores
# out: intermediate files (like weight)
# name: name for the output file
# SAMPLE_SIZE sample size for GWAS you use
## example
# bfile='/lustre04/scratch/liulang/genotype/ukbb_e/GWAS/ukb_chr${chr}.unrelated.caucasian.qc7.10000'
# out_final=~/liulang/lang/project_actigraphy/PRS/
# out=~/scratch/temp_PRS/PRScs_UKB/
# name=UKB_GWAS_PRScs
# SAMPLE_SIZE=563000
bfile=$1
out=$2
out_final=$3
name=$4



# calculate weights for each variant
for chr in {1..22};do 
bfile_prefix=$(echo $bfile| sed "s/\${chr}/${chr}/g")
echo "$bfile_prefix is being calculated"
command="bash /lustre03/project/6004655/COMMUN/runs/lang/scripts/PRS/AD_PRS_cs.sh ${bfile_prefix} ${out} ${name} ${chr}"
#echo $command
echo "${out_final}/${name}_chr${chr}.out"
sbatch -c 10 --mem=20g -t 4:0:0 --wrap "$command" --account=def-grouleau --out ${out_final}/${name}_chr${chr}.out;
done 

sleep 3h


# Loop indefinitely until all files are found
while true; do
  all_files_present=true
  for chr in {1..22};do 
    file=${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt
    if [ ! -f "$file" ]; then
      echo "$it is still calculating, waiting for 30 minutes."
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

# calculate average score for each chromosome (chr1 need extra time)
for chr in {1..22};do 
bfile_prefix=$(echo $bfile| sed "s/\${chr}/${chr}/g")
echo "$bfile_prefix is being calculated"
# plink2 has a skip dup ID feature. this might be problematic if the multiallelic snps are important. but this is usually QCed.
#module load nixpkgs/16.09 StdEnv/2020 plink/2.00-20231024-avx2 && plink2 --bfile $bfile_prefix --score ${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt 2 4 6 ignore-dup-ids --out ${out}/${name}.chr${chr}
command="module load StdEnv/2023 plink/2.00-20231024-avx2 && plink2 --bfile $bfile_prefix --memory 800000 --threads 15 --score ${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt 2 4 6 ignore-dup-ids --out ${out}/${name}.chr${chr}"
sbatch -c 20 --mem=100g -t 2:0:0 --account=def-grouleau --wrap "$command" --out ${out}/${name}.${chr}.score.out
#srun -c 20 --mem=100g -t 2:0:0 --account=def-grouleau --out ${out}/${name}.${chr}.score.out plink2 --bfile $bfile_prefix --memory 800000 --threads 15 --score ${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt 2 4 6 ignore-dup-ids --out ${out}/${name}.chr${chr}
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
    # sum up scores across chromosomes and convert to zscore
    module load StdEnv/2020 scipy-stack/2020a python/3.8.10
    python /lustre03/project/6004655/COMMUN/runs/lang/scripts/PRS/calculate_avg_and_zscore_PRScs_PLINK2.py ${out} ${name} ${out_final}
    break # Exit the while loop
  fi
done




