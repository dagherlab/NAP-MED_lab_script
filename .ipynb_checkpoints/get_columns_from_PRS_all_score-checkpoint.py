import argparse
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("-o","--output")
parser.add_argument("-i","--input")
args = parser.parse_args()

file = args.input

with open(file) as f:
    header = f.readline()
    dat = f.readlines()
#split the string into multiple values
header = header.split()
df = []
for fid in dat:
    df.append(fid.split())
df1 = pd.DataFrame(df)
#assign header to the dataframe
df1.columns = header
#write to a csv file
name = args.output
df1.to_csv(f"{name}_PRS.csv",index = False)
#5x10^-8, 0.001, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 1


