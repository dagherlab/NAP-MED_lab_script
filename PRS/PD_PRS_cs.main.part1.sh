#!/bin/bash
bfile=$1
out=$2 # you should put a folder in scratch. this is for your posterior effect size 
out_final=$3 # this will be dir for your out files and your final PRS
name=$4 # outname
SAMPLE_SIZE=$5
# 63,555 cases, 17,700 proxy cases with a family history of Parkinson's disease, and 1,746,386 control
# 63555+17700+1746386
# calculate weights for each variant
for chr in {1..22};do 
    bfile_prefix=$(echo $bfile|sed "s/#/$chr/")
    if [ ! -f ${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt ];then 
        echo "$bfile_prefix is being calculated"
        command="bash /lustre03/project/6004655/COMMUN/runs/lang/scripts/PRS/PD_PRS_cs.sh $bfile_prefix $out $name $SAMPLE_SIZE $chr"
        echo $command
        echo ${out_final}/${name}_chr${chr}.out
        sbatch -c 10 --mem=20g -t 2:30:0 --wrap "$command" --account=def-grouleau --out ${out_final}/${name}_chr${chr}.out;
    fi 
done 
# how to use
# bash PD_PRS_cs.main.part1.sh "~/scratch/genotype/UKBB_neurohub/PRScs/ukb_chr#" ~/scratch/temp_PRS/PRScs_UKB/ ~/scratch/temp_PRS/PRScs_UKB/ PD 1827641
