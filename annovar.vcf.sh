#!/bin/bash

vcf=$1
out=$2
name=$3


# convert to annovar format
perl /lustre03/project/6004655/COMMUN/soft/src/pipeline_exome.svn/soft/packages/VarAnnot/convert2annovar.pl \
--format vcf4 $vcf \
--allsample --withfreq --outfile $out/${name}_ANNOVAR
###annotate all snps
# download database for hg38
# perl /lustre03/project/6004655/COMMUN/soft/src/pipeline_exome.svn/soft/packages/VarAnnot/annotate_variation.pl -buildver hg38 -downdb -webfrom annovar refGene ~/scratch/reference_file/
# perl /lustre03/project/6004655/COMMUN/soft/src/pipeline_exome.svn/soft/packages/VarAnnot/annotate_variation.pl -buildver hg38 -downdb -webfrom annovar ljb26_all ~/scratch/reference_file/
# perl /lustre03/project/6004655/COMMUN/soft/src/pipeline_exome.svn/soft/packages/VarAnnot/annotate_variation.pl -buildver hg38 -downdb -webfrom annovar dbnsfp41c ~/scratch/reference_file/

perl /lustre03/project/6004655/COMMUN/soft/src/pipeline_exome.svn/soft/packages/VarAnnot/table_annovar.pl \
$out/${name}_ANNOVAR ~/scratch/reference_file/ \
--buildver hg38 --out $out/${name}_ANNOVAR --remove --protocol refGene,ljb26_all,dbnsfp41c --operation g,f,f --nastring .
 