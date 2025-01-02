# how to use 
# module load StdEnv/2020  gcc/9.3.0 r-bundle-bioconductor/3.14 r/4.1.2
# Rscript find_genes_ensembl.r --path path/to/your/gene_list --dir path/to/your/output

.libPaths(c(.libPaths(), "~/runs/eyu8/library/gene_prio", 
            "/cvmfs/soft.computecanada.ca/easybuild/software/2020/avx2/Compiler/gcc9/r-bundle-bioconductor/3.14", 
            "/cvmfs/soft.computecanada.ca/easybuild/software/2020/avx2/Core/r/4.1.2/lib64/R/library"))
library(optparse)
library(biomaRt)
library(data.table)
library(dplyr)
library(plyranges)
library(GenomicRanges)
option_list <- list(
  make_option(c("-p", "--path"), type="character", help="Path to the gene name", metavar="character"),
  make_option(c("-d", "--dir"), type="character", default=".", help="Path to bed files", metavar="character")
)


opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)
# connect to API 
ensembl <- useEnsembl(biomart = "genes", dataset = "hsapiens_gene_ensembl", version = "GRCh37")
all_gene <- getBM(attributes = c('hgnc_symbol', 'chromosome_name', 'start_position', 'end_position'), filters = 'biotype', values = list(biotype="protein_coding"), mart = ensembl)


# load genes
path = opt$path #"path/to/gene_name"

path_name = basename(path)
gene_df = data.frame(fread(path))
genes = gene_df$Gene
# make it all capital
genes = toupper(genes)
all_gene <- getBM(attributes = c('hgnc_symbol', 'chromosome_name', 'start_position', 'end_position'), filters = 'biotype', values = list(biotype="protein_coding"), mart = ensembl)

colnames(all_gene) <- c("gene", "chr", "start", "end")
all_gene.gr <- all_gene %>% filter(chr %in% 1:22, gene %in% genes)
# genes not matched
print("those genes can't be mapped in the database")
print(genes[!genes %in% all_gene.gr$gene])
# make bed file 
## are you gonna extract genes from plink or vcf file? if vcf, check if the chr column comes with prefix "chr", if yes, make sure the generated bed file has prefix chr in the chr column 
## chr prefix 
# bed = all_gene.gr %>% mutate(chr = paste0("chr",chr)) %>% select(chr, start, end, gene)
## no chr prefix 
bed = all_gene.gr %>% select(chr, start, end, gene)
write.table(bed,paste0(opt$dir,"/", path_name,".GRCh37.bed"),sep="\t",row.names=F,col.names=F,quote=F)