#!/bin/bash
#
#
#SBATCH -c 20
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=MakeTSS3
#SBATCH --output=MakeTSS3.out
#SBATCH --time=5:00:00

#https://www.biostars.org/p/158712/#158719
#take all mm10 genes and add 3kb up and downstream
#takes into account strand information
upstream=3000

downstream=3000

cat mm10.refseq.bed | awk '{ if ($6 == "+") { print $1,$2-'$upstream', $2+'$downstream', $4, $5, $6,$7,$8,$9,$10,$11,$12 } else if ($6 == "-") { print $1, $3-'$upstream', $3+'$downstream', $4,$5,$6,$7,$8,$9,$10,$11,$12 }}' > mm10.promoter.bed


 
 #make sure it is tab delim
 sed -e 's/  */\t/g' <mm10.promoter.bed >mm10.promoter.tab.bed
 
 #remove randome chromosomes
 
awk '$1 !~ /_/' mm10.promoter.tab.bed > mm10.promoter.c.bed
 
 #remove chrM
 awk '$1 !~ /chrM/' mm10.promoter.c.bed> mm10.promoter.d.bed


 
 sort -k1,1 -k2,2n mm10.promoter.d.bed > mm10.promoter.sort.bed
