#!/bin/bash
template=$1
old=$2
new=$3
filename=$4

file=letsbatch.txt
new_filename=${filename}${new}.sh
cp $template $new_filename
sed -i "s|$old|$new|g" $new_filename
#generate a script file to sbatch all files
txt="sbatch ${new_filename}"
if [ ! -f "$file" ]; then
touch "$file"
fi
echo "$txt" >> "$file"
