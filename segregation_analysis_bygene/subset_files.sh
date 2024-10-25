#!/bin/bash 


file_path=$1
gene_file=$2
# create a tmp folder in scratch
mkdir -p ~/scratch/tmp


# identify column
select_cols=/lustre03/project/6004655/COMMUN/runs/lang/scripts/segregation_analysis_bygene/headings.txt

header_file=${file_path}/chr1.HSP.segregation

if [[ ! -f $header_file ]]; then echo "ERROR: header_file $header_file doesnt exist"; exit 42; fi


header=$(head -n 1 "$header_file")
IFS=$'\t' read -r -a header_array <<< "$header"
# Function to find index of a column
find_column_index() {
    local column_name=$1
    for i in "${!header_array[@]}"; do
        if [[ "${header_array[i]}" == "$column_name" ]]; then
            echo $((i + 1))
            return
        fi
    done
    echo "None"
}

# Read column names from the file and find their indices
while IFS= read -r column_name; do
    index=$(find_column_index "$column_name")
    if [[ "$index" != "None" ]]; then
        column_indices+=($index)
    fi
done < "$select_cols"

# add 1 to each index 


# Join the indices with commas
indices=$(IFS=,; echo "${column_indices[*]}")
echo $indices
chr=1
file=${file_path}/chr${chr}.HSP.segregation
echo "cutting file $file"
cut -f$indices "$file" > ~/scratch/tmp/chrall.HSP.segregation

# Use the indices with cut -f
for chr in {2..22} X Y;do 
file=${file_path}/chr${chr}.HSP.segregation
echo "cutting file $file"
if [ ! -f $file ];then echo "ERROR: file $file doesnt exist"; exit 41; fi 
cut -f$indices "$file"|tail -n +2  >> ~/scratch/tmp/chrall.HSP.segregation
done


# subset the file with IMPACT and genes
module load StdEnv/2020 python/3.8.10 scipy-stack/2020a
echo "subseting file with IMPACT and genes, please make sure your gene file is a one-column file. all genes are in a column"
python /lustre03/project/6004655/COMMUN/runs/lang/scripts/segregation_analysis_bygene/separate_bygene.py -i ~/scratch/tmp/chrall.HSP.segregation -g /lustre03/project/6004655/COMMUN/runs/lang/scripts/segregation_analysis_bygene/HSP_genes_panel.txt
echo "now your files are saved to ~/scratch/tmp/"


