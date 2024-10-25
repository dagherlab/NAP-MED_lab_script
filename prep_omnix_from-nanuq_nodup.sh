#!/bin/bash

FILENAME=$1

mv genotypes-chrAll.txt raw.ped
mv markerFile-chrAll.txt raw.map

bash /lustre03/project/6004655/COMMUN/runs/lang/scripts/Nanuq_remove_dup_ID.py raw.ped temp.ped
mv temp.ped raw.ped

plink --file raw --make-bed --out $FILENAME --allow-extra-chr --not-chr Bad