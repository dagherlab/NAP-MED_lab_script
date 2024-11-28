#!/bin/bash



# this script calculates pathway PRS based on genes


gene_lists_dir=$1 # it is the folder of gene_list files
output_dir=$2
cohort=$3 # make sure you've QCed your genotyping data
target=$4 # you should make sure bim files contain rsid only instead of positions or rsid:alleles
skip_bed_files=${5:-TRUE}


script_dir=~/lang/scripts/pathway_PRS/ 

if [[ -z $gene_lists_dir ]]; then echo "ERROR: gene_lists_dir (1st arg) not specified"; exit 42; fi
if [[ -z $output_dir ]]; then echo "ERROR: out directory (2nd arg) not specified"; exit 42; fi
if [[ -z $cohort ]]; then echo "ERROR: cohort name (3rd arg) not specified"; exit 42; fi
if [[ -z $target ]]; then echo "ERROR: target (7th arg) not specified"; exit 42; fi
if [[ "$skip_bed_files" != "TRUE" ]];then 
    if [ ! -f bed_files/$name.GRCh38.bed ];then 
        module load StdEnv/2020 python/3.8.10 scipy-stack/2020a
        # most cohorts in our folders are based on GRCh38, UKB is on GRCh37
        echo "getting positions of genes"
        mkdir -p bed_files/
        for gene_list in $gene_lists_dir/*;do 
            python ${script_dir}/map_genes_GRCh37.py -i $gene_list -o bed_files/ -p $name
            python ${script_dir}/map_genes_GRCh38.py -i $gene_list -o bed_files/ -p $name
        done
    fi
    bed_file_dir=bed_file 
else
    bed_file_dir=$gene_lists_dir #bed files are stored in gene_lists_dir
fi


if [[ "$cohort" == "UKB" ]]; then
    echo "UKB cohort is gonna be used. we need to use bed file which is based on GRCh37"
    bed=$(ls -v $bed_file_dir/*.GRCh37.bed| paste -sd,)
    resource="-c 20 --mem=40g -t 5:0:0"
    else
    resource="-c 5 --mem=10g -t 2:30:0"
    bed=$(ls -v $bed_file_dir/*.GRCh38.bed| paste -sd,)
fi 
echo "here are all the bed files in the submission"
echo $bed

echo "do you want to continue and sbatch the job? (Y/n)"
read answer
if [[ "$answer" == "Y" ]];then 
    # bash ${script_dir}/pathway_prs_by_bed.sh $target $bed $output_dir $cohort
    command="bash ${script_dir}/pathway_prs_by_bed.multi.sh $target $bed $output_dir $cohort"
    sbatch $resource --account=rrg-adagher  --wrap "$command" --out $output_dir/$cohort.out --job-name=${cohort}
else
    exit 
fi 
