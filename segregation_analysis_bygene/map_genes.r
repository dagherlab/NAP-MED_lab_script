# module load StdEnv/2020  gcc/9.3.0 r-bundle-bioconductor/3.16 r/4.2.1

library(biomaRt)
library(readr)
library(dplyr)
library(org.Hs.eg.db)
library(AnnotationDbi)
library(glue)
# Function to map gene aliases to canonical names
map_to_canonical <- function(genes) {
    mapped_genes <- AnnotationDbi::mapIds(org.Hs.eg.db,
                                          keys = genes,
                                          column = "SYMBOL",
                                          keytype = "ALIAS",
                                          multiVals = "first")
    return(na.omit(mapped_genes))
}

args <- commandArgs(trailingOnly = TRUE)
path = args[1]
out = args[2]

# Define your list of genes
#path="/home/liulang/lang/scripts/segregation_analysis_bygene/HSP_genes_panel.txt"
genes <- read_tsv(path,col_names=F)$X1




# Use biomaRt to connect to the Ensembl database and specify GRCh37
ensembl <- useEnsembl("genes", "hsapiens_gene_ensembl", version=112)
gene_ids <- getBM(attributes = c("ensembl_gene_id"), mart = ensembl)
gene_ids <- getBM(attributes = c("hgnc_symbol"), mart = ensembl)

info = getBM(attributes = c('chromosome_name',
                   'start_position', 'end_position','hgnc_symbol'),
        filters = 'hgnc_symbol', 
        values = genes, 
        mart = ensembl)
print(dim(info))

# identify genes that are not matched
diff <- setdiff(genes, info$hgnc_symbol)
genes2 <- map_to_canonical(diff)

info2 = getBM(attributes = c('chromosome_name',
                   'start_position', 'end_position','hgnc_symbol'),
        filters = 'hgnc_symbol', 
        values = genes2, 
        mart = ensembl)

print(dim(info2))
diff2 <- setdiff(genes2, info2$hgnc_symbol)
genes2 <- map_to_canonical(diff)
print("these genes cant be found in the database")
print(diff2)

gene_all = data.frame(rbind(info,info2))
gene_all2 = gene_all[,c('chromosome_name','start_position', 'end_position','hgnc_symbol')]
# Write the locations to a BED file
write.table(gene_all2, file = glue("{out}/genes.bed"), sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)