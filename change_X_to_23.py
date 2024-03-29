import argparse
import pandas as pd

parser = argparse.ArgumentParser()
#parser.add_argument("-o","--output")
parser.add_argument("-i","--input")
args = parser.parse_args()
name=args.input #"APDGC_chrX.bim"
name1="soft_calls/"+name
df=pd.read_csv(name1,sep="\t",header=None)
df.columns=["chr","rs","start","pos","a1","a2"]
df.chr = "X"#change chr name from 23 to X
#df["rs"]=list(map(lambda x: x.replace("X","23"),df.rs))
df.to_csv(name1,header=None,index=False,sep="\t")
#hard_calls
name2="hard_calls/"+name
df=pd.read_csv(name2,sep="\t",header=None)
df.columns=["chr","rs","start","pos","a1","a2"]
df.chr = "X"#change chr name from 23 to X
#df["rs"]=list(map(lambda x: x.replace("X","23"),df.rs))
df.to_csv(name2,header=None,index=False,sep="\t")
