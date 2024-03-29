#!/bin/bash
old_chr='${chr}'
file="step7_UKBB_softcall_pruning_sbatch.sh"
#make sure you remove it before you generate it
rm $file
for chr in $(seq 1 22);do 
    new_chr=$chr
    new_filename=step7_UKBB_pruning_and_QC_by_chr${new_chr}.sh
    cp step7_UKBB_pruning_and_QC_template.sh $new_filename
    sed -i "s|$old_chr|$new_chr|g" $new_filename
    #generate a script file to sbatch all files
    txt="sbatch ${new_filename}"
    if [ ! -f "$file" ]; then
    touch "$file"
    fi
    echo "$txt" >> "$file"
done
new_chr=X
new_filename=step7_UKBB_pruning_and_QC_by_chr${new_chr}.sh
cp step7_UKBB_pruning_and_QC_template.sh $new_filename
sed -i "s|$old_chr|$new_chr|g" $new_filename
txt="sbatch ${new_filename}"
echo "$txt" >> "$file"
