
# module load StdEnv/2023 r/4.0.2 gcc/12.3 r-bundle-bioconductor/3.18
library(data.table)
library(glue)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)
path=args[1]

df <- data.frame(fread(args[1]))

path="/lustre03/project/6004655/COMMUN/runs/rambani1/HSP_exomes/results"