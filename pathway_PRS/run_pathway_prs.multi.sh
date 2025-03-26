#!/bin/bash



# this script calculates pathway PRS based on genes


gene_lists_dir=$1 # it is the folder of gene_list files
bed_file_dir=$2
output_dir=$3
cohort=$4 # make sure you've QCed your genotyping data
target=$5 # you should make sure bim files contain rsid only instead of positions or rsid:alleles
phenotype=$6 # AD or PD
skip_bed_files=${7:-FALSE}

bed_file_dir="$(cd "$(dirname "$bed_file_dir")" && pwd)/$(basename "$bed_file_dir")"


echo "gene_lists_dir ${gene_lists_dir}"
echo "bed_file_dir ${bed_file_dir}"
echo "cohort ${cohort}"
echo "target ${target}"
echo "phenotype ${phenotype}"
echo "skip_bed_files ${skip_bed_files}"
echo "output_dir ${output_dir}"


script_dir=~/lang/scripts/pathway_PRS/ 

if [[ -z $gene_lists_dir ]]; then echo "ERROR: gene_lists_dir (1st arg) not specified"; exit 42; fi
if [[ -z $bed_file_dir ]]; then echo "ERROR: bed_file_dir (2nd arg) not specified"; exit 42; fi
if [[ -z $output_dir ]]; then echo "ERROR: out directory (3rd arg) not specified"; exit 42; fi
if [[ -z $cohort ]]; then echo "ERROR: cohort name (4th arg) not specified"; exit 42; fi
if [[ -z $target ]]; then echo "ERROR: target (5th arg) not specified"; exit 42; fi
if [[ -z $phenotype ]]; then echo "ERROR: phenotype (6th arg) not specified"; exit 42; fi

if [[ "$skip_bed_files" != "TRUE" ]];then 
    if [ ! -f ${bed_file_dir}/$name.*.bed ];then 
        module load StdEnv/2020 python/3.8.10 scipy-stack/2020a
        # most cohorts in our folders are based on GRCh38, UKB is on GRCh37
        echo "getting positions of genes"
        mkdir -p ${bed_file_dir}/
        for gene_list in $gene_lists_dir/*;do 
            python ${script_dir}/map_genes_GRCh37.py -i $gene_list -o ${bed_file_dir}/ -p $name
            python ${script_dir}/map_genes_GRCh38.py -i $gene_list -o ${bed_file_dir}/ -p $name
        done
    fi
fi


if [[ "$cohort" == "UKB" ]]; then
    echo "UKB cohort is gonna be used. we need to use bed file which is based on GRCh37"
    bed=$(ls -v ${bed_file_dir}/*.GRCh37.bed| paste -sd,)
    resource="-c 20 --mem=100g -t 8:0:0"
    else
    resource="-c 5 --mem=10g -t 2:30:0"
    bed=$(ls -v ${bed_file_dir}/*.GRCh38.bed| paste -sd,)
fi 
echo "here are all the bed files in the submission"
echo $bed

echo "do you want to continue and sbatch the job? (Y/n)"
read answer
if [[ "$answer" == "Y" ]];then 
    # bash ${script_dir}/pathway_prs_by_bed.multi.${phenotype}.sh $target $bed $output_dir $cohort
    command="bash ${script_dir}/pathway_prs_by_bed.multi.${phenotype}.sh $target $bed $output_dir $cohort"
    sbatch $resource --account=rrg-adagher  --wrap "$command" --out $output_dir/$cohort.${phenotype}.out --job-name=${cohort}.${phenotype}
else
    exit 
fi 
