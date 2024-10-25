## map gene names to their coordinates (GRCh38)
#module load python/3.8.10 scipy-stack/2020a
#step1
print("loading packages")
import argparse
import pandas as pd
import warnings
warnings.filterwarnings('ignore')
parser = argparse.ArgumentParser()
parser.add_argument("-o","--output")
parser.add_argument("-i","--input")
parser.add_argument("-p","--pathname")
parser.add_argument("-r","--recode")

recode = False


args = parser.parse_args()
if args.recode:
    recode = True
    print(args.recode)
    print("data will be recoded (chr2 -> 2; chrX -> 23)")
path = args.input
#path='/lustre03/project/6004655/COMMUN/runs/senkkon/2023/LysUKBB/lysgenes.txt'
with open(path,"r") as f:
    genes = f.read().strip()
genes = genes.split("\n")
pathname = args.pathname

#ok I don't wanna manually retrieve the coordinates for each gene
#get gff file and see if I can retrieve it
### check the reference genome before you read them
## GRCh38
# ref=pd.read_csv("~/runs/go_lab/gencode/gencode.v44.annotation.gtf",sep = "\t",skiprows=5,header=None)
## GRCh37 (uncomment this for GRCh37)
ref=pd.read_csv("~/runs/go_lab/gencode/gencode.v40lift37.annotation.gtf",sep = "\t",skiprows=5,header=None)

ref.columns = ["seqname","source","feature","start","end","score","strand","frame","attribute"]
ref = ref[ref.feature == "gene"]#only gene is the one we are looking at
##retrieve coordinates for genes
def get_gene_name(s):
    s = s.split(";")
    temp = list(map(lambda x: x.startswith(" gene_name"), s))
    s = pd.Series(s)
    gene_name = s[temp].iloc[0].split()[1].strip('"')
    return gene_name

ref["gene_name"] = list(map(lambda x: get_gene_name(x),ref.attribute))
ref = ref[["seqname","start","end","gene_name"]]
ref.columns = ["chr","start","end","gene"]


##get all genes and their coordinates
all = genes
all_df = ref[ref.gene.isin(set(all))]
if recode:
    all_df["chr"] = all_df.chr.str.split("chr",expand=True)[1]
    # all_df.loc[all_df.chr=="X","chr"] = 23

### Problem solved
## check mismatched genes 49/50 matched. there is an empty string (GBA should be GBA1)
print("here are mismatched genes")
print(set(all) ^ set(list(all_df.gene)))
if len(set(all) ^ set(list(all_df.gene))) > 0:
    print("the program is terminated because there are mismatched genes")
    exit()


#make bed files
p = pathname
out = args.output
print("the results bed file")
print(all_df)
all_df.to_csv(f"{out}/{p}.GRCh37.bed",sep = "\t", index=False, header=None)