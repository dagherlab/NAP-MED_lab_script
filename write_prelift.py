#write_prelift.py
import argparse
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("-o","--output")
parser.add_argument("-i","--input")
args = parser.parse_args()

file = args.input
try:
    df = pd.read_csv(file,sep = "\t")
    keep = ["CHR","BP","SNP"]
    df_keep = df[keep]
except:
    print("please make sure the file is separated by tab")
df_keep.CHR = "chr" + df_keep.CHR.astype(str)
df_keep["BP2"] = df.BP
order = ["CHR","BP","BP2","SNP"]
#remove empty fields
df_keep.dropna(inplace=True)
pre_lift = df_keep[order]
out = args.output
pre_lift.to_csv(out,sep = "\t",index=False,header=False)
