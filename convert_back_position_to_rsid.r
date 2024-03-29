#module load r/4.0.2

library("optparse")
library("data.table")
library("glue")

option_list = list(
  make_option(c("-b", "--bed"), type="character", default=NULL, 
              help="bed file name", metavar="character"),
  make_option(c("-p", "--position"), type="character", default=NULL, 
              help="file to be converted back", metavar="character"),
  make_option(c("-o", "--path"), type="character", default=NULL, 
              help="path to your input and output", metavar="character"),
  make_option(c("-c", "--column"), type="numeric", default=NULL, 
              help="column number", metavar="numeric"),
  make_option(c("-H", "--header"), type="logical", default=FALSE, 
              help="column header present or not", metavar="logical")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
filename=basename(opt$position)
path=dirname(opt$position)
#filename="AD_PD_PHS.frq"
file_extension <- sub(".*\\.", "", filename)
prefix = sub("\\..*$", "", filename)
output= glue("{prefix}.rsid.{file_extension}")
#position = data.frame(fread(filename,header=TRUE))
#col_position = as.numeric("2")


position = data.frame(fread(opt$position,header=opt$header))
columns = names(position)
col_position = as.numeric(opt$column)
col_name = names(position)[col_position]
bed = data.frame(fread(opt$bed,header=FALSE))
names(bed)
#bed = data.frame(fread("AD_PD_PHS_SNPs.GRCh38.txt"))
# add chr:pos column to bed file
names(bed) = c("CHR","START","END","rs")
bed["rename"] = paste(bed$CHR,bed$START,sep=":")
bed = bed[c("rs","rename")]

convert = merge(position,bed,by.x = col_name, by.y = "rename")
convert[col_name] = convert$rs
convert = convert[columns]

path=paste(path,output,sep='/')
write.table(convert,path,sep="\t",row.names=FALSE,col.names=opt$header,quote=FALSE)


