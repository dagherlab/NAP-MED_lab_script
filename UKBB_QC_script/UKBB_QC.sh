export SLURM_ACCOUNT=def-grouleau
export SBATCH_ACCOUNT=$SLURM_ACCOUNT
export SALLOC_ACCOUNT=$SLURM_ACCOUNT

#####################
#this is for PRS calculation
#####################
# neurohub's UKBB's European ancestry, pcs and outliers have been detected
# the only thing we need to do is to perform variant-level QC
# there is no need for sample-level qc


# summary
## 1. get maf below 1% and info score >= 0.3 from txt files
## 2. standard gwas qc hwe 1e-6 geno 0.01 (mind not included, maf already performed)


# bgen file is in 
## /lustre03/project/6008063/neurohub/ukbb/new/Bulk/Imputation/UKB_imputation_from_genotype/

# remove variants with minor allele frequency (MAF) below 1% and with an imputation information score below 0.3
## ukb_mfi_chr#_v3.txt contains maf and info values
## we'd like to get variants ID
for i in $(seq 1 22) X;do
awk -F'\t' -v OFS='\t' '$6 >= 0.01 && $8 >= 0.3 {print $2}' ukb_mfi_chr${i}_v3.txt > ukb_chr${i}.qc.snp.list;
done

# extract those variants and perform basic GWAS QC. mind 0.01, geno 0.01 and hwe 1e-6 and 
info_path=/home/liulang/scratch/genotype/UKBB_new_imputation/imputation_scores/
bgen_path=/lustre03/project/6008063/neurohub/ukbb/new/Bulk/Imputation/UKB_imputation_from_genotype/
out=/home/liulang/scratch/genotype/UKBB_new_imputation/qc/
# don't do extract --extract ${info_path}/ukb_chr${i}.qc.snp.list yet
for i in $(seq 1 22) X;do
command="module load StdEnv/2020 plink/2.00a3.6 && plink2 --bgen ${bgen_path}/ukb22828_c${i}_b0_v3.bgen ref-first --sample ${bgen_path}/ukb22828_c${i}_b0_v3.sample --hwe 1e-6 --geno 0.01 --rm-dup force-first --make-bed --out ${out}/ukb22828_c${i}_b0_v3.qc"
sbatch -c 40 --mem=60g -t 6:0:0 --wrap "$command" --account=def-grouleau --out ${out}/ukb22828.qc.chr${i}.out
done
# some chr need extra resources
for i in 5 7 12 21;do
command="module load StdEnv/2020 plink/2.00a3.6 && plink2 --bgen ${bgen_path}/ukb22828_c${i}_b0_v3.bgen ref-first --sample ${bgen_path}/ukb22828_c${i}_b0_v3.sample --hwe 1e-6 --geno 0.01 --rm-dup force-first --make-bed --out ${out}/ukb22828_c${i}_b0_v3.qc"
sbatch -c 40 --mem=60g -t 6:0:0 --wrap "$command" --account=def-grouleau --out ${out}/ukb22828.qc.chr${i}.out
done

# European and qualified files
~/projects/def-grouleau/liulang/project_tau/UKBB/ukbb_pc_unrelated_European.csv