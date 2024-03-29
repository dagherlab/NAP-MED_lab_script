#!/usr/bin/env Rscript
library(data.table)
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)!=3) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
  } 

## program...
output = args[3]
output = paste(output,".valid",sep='')
valid = args[1]
valid = fread(valid)
dat = args[2]
dat = fread(dat)[FID%in%valid$FID]
fwrite(dat[STATUS=="OK",c("FID","IID")], output, sep="\t") 
q() # exit R
