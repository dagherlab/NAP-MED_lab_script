import pandas as pd
import numpy as np
import sys
import os


# this script file can take sscore files produced by plink2 and get the average score across chromosomes.
def calculate_zscored_average(input_dir, file_prefix, output_dir):
    scores = []
    for chr_num in range(1, 23):
        file_name = f"{file_prefix}.chr{chr_num}.txt"
        file_path = os.path.join(input_dir, file_name)
        if os.path.exists(file_path):
            df = pd.read_csv(file_path, sep='\t')
            scores.append(df.iloc[:, -1])  # Assumes SCORE1_AVG is always the last column
        else:
            print(f"File {file_name} does not exist. Skipping...")
    
    if len(scores) == 22:
        combined_scores = pd.concat(scores, axis=1)
        avg_score = combined_scores.mean(axis=1)
        zscored_avg_score = (avg_score - avg_score.mean()) / avg_score.std()

        # Assuming FID and IID are the same across all files and taking them from the last read file
        result = df[['FID', 'IID']].copy()
        result['PRScs_z'] = zscored_avg_score

        output_file = os.path.join(output_dir, f"{file_prefix}_zscored.csv")
        result.to_csv(output_file, index=False)
        print(f"Output saved to {output_file}")
    else:
        print("we are missing scores.")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <input_dir> <file_prefix> <output_dir>")
        sys.exit(1)
    
    input_dir = sys.argv[1]
    file_prefix = sys.argv[2]
    output_dir = sys.argv[3]

    calculate_zscored_average(input_dir, file_prefix, output_dir)
