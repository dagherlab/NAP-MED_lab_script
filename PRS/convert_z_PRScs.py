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
df = pd.read_csv(file,sep = r'\s+')
#final output df
output = df.copy()
output["SCORESUM_Z"] = zscore(df["SCORESUM"])

#write to a csv file
name = args.output
output.to_csv(f"{name}_zscore.csv",index = False)



