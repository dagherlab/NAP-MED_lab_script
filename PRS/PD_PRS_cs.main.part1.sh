#!/bin/bash
bfile=$1
out=$2
out_final=$3
name=$4
SAMPLE_SIZE=$5

# calculate weights for each variant
for chr in {1..22};do 
    bfile_prefix=$(echo $bfile|sed "s/#/$chr/")
    if [ ! -f ${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt ];then 
        echo "$bfile_prefix is being calculated"
        command="bash /home/liulang/lang/scripts/PRS/PD_PRS_cs.sh $bfile_prefix $out $name $SAMPLE_SIZE $chr"
        echo $command
        #echo ${out}/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt
        #echo ${out_final}/${name}_chr${chr}.out
        echo ${out_final}/${name}_chr${chr}.out
        sbatch -c 10 --mem=20g -t 2:30:0 --wrap "$command" --account=def-grouleau --out ${out_final}/${name}_chr${chr}.out;
    fi 
done 

