#merge_afterlift.py
import argparse
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("-o","--output")
parser.add_argument("-r","--reference")
parser.add_argument("-i","--input")
args = parser.parse_args()

file = args.input
original_file = args.reference
output = args.output
df = pd.read_csv(file,sep = "\t",header=None)
df.columns = ["CHR","START","END","SNP"]
df.drop(['START',"CHR"],axis = 1 , inplace=True)#chr notation is inconsistent
reference = pd.read_csv(original_file, sep = "\t")
reference.drop(["BP"],axis = 1 ,inplace=True)
#merge files
merge = pd.merge(df,reference,on = "SNP")
merge.to_csv(output,sep = "\t",index = False)

