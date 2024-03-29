###remove non actg and generate a list of variants that should be keeped
#two columns
import argparse
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("-o","--output")
parser.add_argument("-d","--duplicate")
parser.add_argument("-i","--input")
args = parser.parse_args()

file = args.input

df = pd.read_csv(file,sep="\t",header=None)
df.columns = ["Chr","SNP","Position","BP","A1","A2"]
#Convert allele into uppercase
df["A1"] = list(map(lambda x: x.upper(), df.A1))
df["A2"] = list(map(lambda x: x.upper(), df.A2))
def check_actg(x):
    actg = ["A","C","T","G"]
    check = list(map(lambda x: x in actg, x))#list of true of false
    return False in check #return True if there is a mismatch/non-actg

non_actg_A1 = list(df.loc[list(map(lambda x: check_actg(x),df.A1)),"SNP"])#list of non-ACTG snps
non_actg_A2 = list(df.loc[list(map(lambda x: check_actg(x),df.A2)),"SNP"])#list of non-ACTG snps
non_actg = non_actg_A1 + non_actg_A2

#remove duplicates (no keep)
df.drop_duplicates(subset = ["SNP"] , keep = False, inplace = True)#dont keep duplicates
SNP = list(df.SNP)

#output files
output = pd.DataFrame({"col1":non_actg,"col2":non_actg})#duplicate columns
name = args.output
output.to_csv(name,sep="\t",index=False,header=False)

name = args.duplicate
output_keep = pd.DataFrame({"col1":SNP,"col2":SNP})
output_keep.to_csv(name,sep="\t",index=False,header=False)
print(output,"generated")
