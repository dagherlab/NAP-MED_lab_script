#!/bin/bash
old_chr='${chr}'
file="step3_UKBB_bgen_to_pgen_sbatch.sh"
#make sure you remove it before you generate it
rm $file
for chr in $(seq 1 22);do 
new_chr=$chr
new_filename=step2_convert_ukbb_bgen_pgen_by_chr${new_chr}.sh
cp step1_convert_ukbb_bgen_pgen_by_chr_template.sh $new_filename
sed -i "s|$old_chr|$new_chr|g" $new_filename
#generate a script file to sbatch all files
txt="sbatch ${new_filename}"
if [ ! -f "$file" ]; then
  touch "$file"
fi
echo "$txt" >> "$file"
done
new_chr=X
new_filename=step2_convert_ukbb_bgen_pgen_by_chr${new_chr}.sh
cp step1_convert_ukbb_bgen_pgen_by_chr_template.sh $new_filename
sed -i "s|$old_chr|$new_chr|g" $new_filename
txt="sbatch ${new_filename}"
echo "$txt" >> "$file"
