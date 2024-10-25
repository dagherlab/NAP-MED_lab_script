# how to use
# module load StdEnv/2020 python/3.8.10 scipy-stack/2020a
# srun -c 40 --mem=100g -t 2:0:0 --account=def-grouleau python separate_bygene.py -i path/to/your/segregation/files/directory -g path/to/your/gene_list



import pandas as pd
import argparse
import warnings
import subprocess
import os


warnings.filterwarnings('ignore')

parser = argparse.ArgumentParser()
parser.add_argument("-i","--input")
parser.add_argument("-g","--genes")
args = parser.parse_args()


path = args.input
# path = "/lustre03/project/6004655/COMMUN/runs/rambani1/HSP_exomes/results"
genes = args.genes
# genes = "/lustre03/project/6004655/COMMUN/runs/lang/scripts/segregation_analysis_bygene/HSP_genes_panel.txt"
with open(genes) as f:
    gene_list = f.read().split()
path=args.input
df_large = pd.read_csv(path,sep="\t", header=0,low_memory=False.)
print("include variants which are in our gene list")
df_large2 = df_large.loc[df_large.SYMBOL.isin(gene_list)]
# identify which genes can't be found in the file

diff = set(gene_list) - set(df_large.SYMBOL)
print(f"there are {diff} genes that can't be found in segregation files")
print(set(gene_list) - set(df_large.SYMBOL))

print("selecting variants which are having high impact (MODIFIER, HIGH and MODERATE)")
df_large3 = df_large2.loc[df_large2.IMPACT.isin(["MODIFIER","HIGH","MODERATE"])]
print(df_large3.groupby("IMPACT").size())
print("among these variants, we have genes")
print(set(df_large3.SYMBOL))
pd.set_option('display.max_rows', len(set(df_large3.SYMBOL)) * 3)  # You can set this to any number you need
print("and here are IMPACT by genes")
print(df_large3.groupby(["SYMBOL","IMPACT"]).size())
print("saving files")
df_large2.to_csv("~/scratch/tmp/HSP.segregation.bygene.tsv",sep="\t",index=False)
df_large3.to_csv("~/scratch/tmp/HSP.segregation.bygene.byimpact.tsv",sep="\t",index=False)
