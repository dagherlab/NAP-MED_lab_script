#!/bin/bash
## For PD PRS calculation using PRScs
## all SNPs in Nalls PD GWAS summary statistics will be used.
bfile_prefix=$1
out=$2
name=$3
SAMPLE_SIZE=$4
chr=$5


# Record the start time
start_time=$(date +%s)
# to keep the format of my original script. I did some stupid repetitive coding below
# change here to your processed GWAS
SUM_STATS_FILE=~/scratch/GWAS/PD/PD_GWAS_2025.tab.PRScs
OUTPUT_DIR=$out
chr=$chr
module load scipy-stack/2020a python/3.8.10 
## under /home/liulang/runs/lang/software/PRScs
### run the following before your run PRScs
N_THREADS=10
export MKL_NUM_THREADS=$N_THREADS
export NUMEXPR_NUM_THREADS=$N_THREADS
export OMP_NUM_THREADS=$N_THREADS
### default flag
PATH_TO_REFERENCE="/lustre03/project/6004655/COMMUN/runs/lang/software/LD_reference/ldblk_1kg_eur";
VALIDATION_BIM_PREFIX=$bfile_prefix
SCRIPT_DIR="/lustre03/project/6004655/COMMUN/runs/lang/software/PRScs"
GWAS_SAMPLE_SIZE=$SAMPLE_SIZE;

if [ -f $SUM_STATS_FILE ];then 
echo "the summary stat file for PD $SUM_STATS_FILE is present"
else
echo "please re-specify the path for your PD GWAS summary stat"
fi 

echo "start running iterations"
mkdir -p ${OUTPUT_DIR}/
python -u ${SCRIPT_DIR}/PRScs.py --ref_dir=$PATH_TO_REFERENCE --bim_prefix=$VALIDATION_BIM_PREFIX --sst_file=$SUM_STATS_FILE --n_gwas=$GWAS_SAMPLE_SIZE --chrom=$chr --out_dir=${OUTPUT_DIR}/${name}
#sbatch -c 5 --mem=10g -t 3:0:0 --wrap "$command" --account=def-grouleau --out ${OUTPUT_DIR}/log.out;


# Record the end time
end_time=$(date +%s)
# Calculate the duration
duration=$((end_time - start_time))
# Print the duration
echo "Duration: ${duration} seconds"