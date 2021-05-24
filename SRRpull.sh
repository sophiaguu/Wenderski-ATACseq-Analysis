#!/bin/bash
#
#SBATCH -c 2
#SBATCH --mem-per-cpu=2000
#SBATCH --job-name=SRAfetch
#SBATCH --output=SRAfetch.out
#SBATCH --time=12:00:00


#ATACseq analysis
#pull SRA files from GEO: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE107436
#######################################################################################
# run from in data  directory
#puts data in shared data file for the experiment
#######################################################################################
mkdir -p SRA/
mkdir -p output/SRA_checksum

for sample in `cat SRR_Acc_List.txt`
do

cd SRA/

echo ${sample} "starting SRR pull"
prefetch ${sample}

#######################################################################################
#paired end sra > Fastq.gz
#######################################################################################

echo ${sample} "starting dump"

#paired end
fastq-dump --origfmt --split-files --gzip ${sample}

#single end
#fastq-dump --origfmt --gzip ${sample}

echo ${sample} "done"

cd ..

#######################################################################################
#validate each SRA file and save to output log
#https://reneshbedre.github.io/blog/fqutil.html
#######################################################################################

echo ${sample} "starting sra check"

vdb-validate SRA/${sample} 2> output/SRA_checksum/${sample}_SRAcheck.log

echo ${sample} "done"

done

#combine logs into one output file
cat output/SRA_checksum/*_SRAcheck.log > output/SRA_checksum/SRAcheck.log

