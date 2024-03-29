library("rsnps")
library("optparse")
library("data.table")

option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL, 
              help="dataset file name", metavar="character"),
  make_option(c("-o", "--path"), type="character", default=NULL, 
              help="path to your input and output", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
filename=basename(opt$input)
path=dirname(opt$input)
output= paste(sub("\\..*$", "", filename),".GRCh38.txt",sep='')

snps = data.frame(fread(opt$input,header=FALSE))
snps <- snps$V1
print(length(snps))
print("snps present in the list")
# default is GRCh38, can check the column assembly
ncbi = ncbi_snp_query(snps)
print(dim(ncbi))
print("snps obtained from NCBI")

# generate bed file
bed = data.frame(list(chr = ncbi$chromosome, start=ncbi$bp, end = ncbi$bp, name = ncbi$query))
path=paste(path,output,sep='/')
write.table(bed,path,sep="\t",row.names=FALSE,col.names=FALSE,quote=FALSE)


