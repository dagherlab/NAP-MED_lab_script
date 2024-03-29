#!/bin/bash
read prelift output_name output_folder genome_build_you_wanna_convert <<< $@

echo "the file is converting to ${genome_build_you_wanna_convert}"
echo "step1, writing the prelift file, make sure your files contain CHR, BP, SNP these 3 columns and it a tab file if anything goes wrong here"
module load python/3.8.10 scipy-stack/2020a
python ~/runs/lang/scripts/write_prelift.py -i $prelift -o ${output_folder}/${output_name}_prelift.tsv
echo "step2, liftovering"
if [ $genome_build_you_wanna_convert == hg38 ]
then
    ~/runs/lang/software/liftOver \
    ${output_folder}/${output_name}_prelift.tsv \
    /lustre04/scratch/liulang/liftover/hg19ToHg38.over.chain \
    ${output_folder}/${output_name}_afterlift.tsv \
    ${output_folder}/${output_name}_unmapped.tsv
elif [ $genome_build_you_wanna_convert == hg19 ]
then 
    ~/runs/lang/software/liftOver \
    ${output_folder}/${output_name}_prelift.tsv \
    /lustre04/scratch/liulang/liftover/hg38ToHg19.over.chain \
    ${output_folder}/${output_name}_afterlift.tsv \
    ${output_folder}/${output_name}_unmapped.tsv
else
    echo "please enter either hg38 or hg19"
    exit 128
fi

echo "step3, converting afterlift file to GWAS summary statistics by merging"
python ~/runs/lang/scripts/merge_afterlift.py \
    -i ${output_folder}/${output_name}_afterlift.tsv \
    -r $prelift \
    -o ${output_folder}/${output_name}.tsv




