#!/bin/bash
# how to use
# bash get_genotypes.sh ~/runs/rambani1/HSP_exomes/analysis/joint-call.vcf.gz /lustre03/project/6004655/COMMUN/runs/lang/scripts/segregation_analysis_bygene/HSP_genes_panel.txt
VCF_FILE=$1
genes=$2
echo "make sure you run this script in a screen"

echo "reading genes and generate a bed file for all genes"
# dont request a node when you are doing this because it is connected to an API
# if this fails, do it again after 1 min
module load StdEnv/2020  gcc/9.3.0 r-bundle-bioconductor/3.16 r/4.2.1
Rscript /lustre03/project/6004655/COMMUN/runs/lang/scripts/segregation_analysis_bygene/map_genes.r \
    $genes \
    ~/scratch/tmp/



module load StdEnv/2023 gcc/12.3 bcftools/1.19

BED_FILE=~/scratch/tmp/genes.bed
# VCF_FILE=~/runs/rambani1/HSP_exomes/analysis/joint-call.vep.vcf.gz
srun -c 5 --mem=10g -t 3:0:0 --account=def-grouleau bcftools view -R $BED_FILE $VCF_FILE > ~/scratch/tmp/HSP.vcf
# add chr:bp:a1:a2 to the column
awk 'BEGIN {FS=OFS="\t"} 
{
    if ($1 ~ /^#/) {
        print $0
    } else {
        $3 = $1":"$2":"$4":"$5
        print $0
    }
}' ~/scratch/tmp/HSP.vcf > ~/scratch/tmp/HSP.withlocation.vcf

# annotate
echo "annotating files, this will take a while"
module load StdEnv/2020 intel/2020.1.217 tabix

awk 'BEGIN{FS=OFS="\t"}{if($1 ~ /^##/){print $0} else{print $1,$2,$3,$4,$5,$6,$7,$8,$9}}' ~/scratch/tmp/HSP.withlocation.vcf > ~/scratch/tmp/HSP.snp.only.vcf
bgzip -c ~/scratch/tmp/HSP.snp.only.vcf > ~/scratch/tmp/HSP.snp.only.vcf.gz; tabix -p vcf  ~/scratch/tmp/HSP.snp.only.vcf.gz;

srun -c 5 --mem=10g -t 6:0:0 --account=def-grouleau bcftools annotate -a /lustre02/home/eyu8/runs/eyu8/data/liftOver/dbsnp151_GRCh37p13-All.biallelic.vcf.gz -c ID ~/scratch/tmp/HSP.snp.only.vcf.gz -o ~/scratch/tmp/HSP.snp.annotated.vcf;



module load StdEnv/2023 plink/2.00-20231024-avx2
# --output-chr M for recoding 23 to X
srun -c 5 --mem=10g -t 3:0:0 --account=def-grouleau plink --vcf ~/scratch/tmp/HSP.withlocation.vcf --make-bed --out ~/scratch/tmp/HSP.withlocation --output-chr M


awk 'BEGIN{FS=OFS="\t"}{if(NR==FNR){snp=$1":"$2":"$4":"$5; rs[snp]=$3; next;} snpa=$1":"$4":"$5":"$6; snpb=$1":"$4":"$6":"$5; if(rs[snpa]>0){$2=rs[snpa]} if(rs[snpb]>0){$2=rs[snpb]} print $0}' <(grep -v "^#" ~/scratch/tmp/HSP.snp.annotated.vcf | grep rs) /home/liulang/scratch/tmp/HSP.withlocation.bim > /home/liulang/scratch/tmp/HSP.withrsid.bim
cp /home/liulang/scratch/tmp/HSP.withlocation.fam /home/liulang/scratch/tmp/HSP.withrsid.fam 
cp /home/liulang/scratch/tmp/HSP.withlocation.bed /home/liulang/scratch/tmp/HSP.withrsid.bed
srun -c 5 --mem=10g -t 3:0:0 --account=def-grouleau plink --bfile /home/liulang/scratch/tmp/HSP.withrsid --recode --out /home/liulang/scratch/tmp/HSP.withrsid
srun -c 5 --mem=10g -t 3:0:0 --account=def-grouleau plink --bfile /home/liulang/scratch/tmp/HSP.withrsid --recode AD --out /home/liulang/scratch/tmp/HSP.withrsid
