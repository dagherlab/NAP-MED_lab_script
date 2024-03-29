#!/bin/bash

read bfile maf hwe geno mind output_name output_folder <<< $@




#check genome build
#liftover the GWAS file when the genome build of the target doesn't match
echo "all the output file is gonna be written in the folder ${output_folder}"
out=${output_folder}/${output_name}
echo "step 1, running standar gwas with maf ${maf}, hwe ${hwe}, geno ${geno}, mind ${mind}"
#standard gwas
module load plink/1.9b_6.21-x86_64
plink \
    --bfile $bfile \
    --maf $maf \
    --hwe $hwe \
    --geno $geno \
    --mind $mind \
    --write-snplist \
    --make-just-fam \
    --out $out
echo "step2, running pruning"
#pruning
plink \
    --bfile $bfile \
    --keep $out.fam \
    --extract $out.snplist \
    --indep-pairwise 200 50 0.25 \
    --out $out
echo "step3, running heterozygosity check"
#heterozygosity
plink \
    --bfile $bfile \
    --extract $out.prune.in \
    --keep $out.fam \
    --het \
    --out $out
echo "step3 next, removing high f coefficient"
#remove by f coef
module load r/4.0.2
Rscript /home/liulang/runs/lang/scripts/remove_high_F_coef.r ${out}.het ${out}

#mismatching SNPs can be detected by PRSice
echo "step4, running sex check is required when there is no sex check before QC"
#sex check requires X chr
<<comment
plink \
    --bfile $bfile \
    --extract ${out}.prune.in \
    --keep ${out}.valid.sample \
    --check-sex \
    --out ${out}
echo "step4 next, extract valid sex check samples"

module load r/4.0.2
Rscript /home/liulang/runs/lang/scripts/sexcheck.r ${out}.valid.sample ${out}.sexcheck ${out}
comment

#relatedness is usually checked by Eric, if not, that will be an issue
echo "step5, make sure there is a relatedness file, otherwise, you need to run this step"
plink \
    --bfile $bfile \
    --extract ${out}.prune.in \
    --keep ${out}.valid.sample \
    --rel-cutoff 0.125 \
    --out ${out}

echo "step6, generate QC file and remove duplicates"
module load StdEnv/2020 plink/2.00a3.6
plink2 \
    --bfile $bfile \
    --make-bed \
    --keep ${out}.rel.id \
    --rm-dup force-first \
    --out ${out} \
    --extract ${out}.snplist \

