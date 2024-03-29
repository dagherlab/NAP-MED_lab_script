#!/usr/bin/env Rscript
library(data.table)
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)!=2) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
  } 

  ## program...
  output = args[2]
  output = paste(output,".valid.sample",sep='')

  # Read in file
  dat <- fread(args[1])
  # Get samples with F coefficient within 3 SD of the population mean
  valid <- dat[F<=mean(F)+3*sd(F) & F>=mean(F)-3*sd(F)] 
  # print FID and IID for valid samples
  ## sometimes it need to be switched between #FID and FID
  fwrite(valid[,c("#FID","IID")],output, sep="\t") 
  q() # exit R
