import argparse
import pandas as pd
from scipy.stats import zscore
import warnings
warnings.filterwarnings('ignore')

parser = argparse.ArgumentParser()
parser.add_argument("-o","--output")
parser.add_argument("-i","--input")
args = parser.parse_args()

file = args.input
df = pd.read_csv(file)
#it contains FID and IID at the begining 
columns = df.columns
id_column = columns[0:2]

#final output df
output = df.copy()
#iterate all the non_id columns
for i in range(2,len(columns)):
    name = columns[i]
    name = name + "_zscore"
    output[name] = zscore(df.iloc[:,i])
#write to a csv file
name = args.output
output.to_csv(f"{name}_zscore.csv",index = False)


