# Wenderski-ATACseq-Analysis

Processing ATAC-seq PE files sourced from the Crabtree Lab: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7211998/.

The ATACseq dataset is downloaded from published PE ATAC-seq files from GEO Accession (https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE147056) and processing them for QC, aligning and analysis in Rstudio. The analysis is setup to run on the DMCBH Alder computing cluster using bash scripts.

# Step 1: Fetching Data from GEO

We will be analyzing ATACseq dataset from the following paper:https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7211998/.

The data is stored in NCBI GEO as SRR files which are highly compressed files that can be converted to fastq files using SRA Toolkit: https://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP252982&o=acc_s%3Aa.

To download a text file of SRR files, use the Run Select function. Navigate to the bottom of the page and select all the ATAC-seq data. Be careful to not select any RNA-seq data. Download "Accession List".

### Make a directory for the experiment in your home directory

Code: cd ~/ && mkdir Wenderski_ATACseq

Make a copy of the SRR_Acc.List.txt file in your home directory.

Code: cd ~/Wenderski_ATACseq
nano SRR_Acc_List.txt

### Run the SRRpull.sh script

The script is setup to run from the experiment directory inside home directory.

It makes a SRA directory in the experiment directory and uses a loop to pull each SRR file in SRR_Acc_List.txt using prefetch.

We added --split to fastq-dump command to get R1 and R2 fastq for each SRR entry because the files are PE.

Make a SRRpull.sh script in the experiment directory and run the script as sbatch submission to Alder.

Code: sbatch SRRpull.sh

Check to see if the script is running.

Code: squeue

Can also check to see if SRAfetch is running properly by checking the contents of the experiment directory to see if a SRAfetch.out has been generated.

Code: less SRAfetch.out (press q to quit)

This can also be used to monitor the progress of SRAfetch.

Once the script has finished running, make sure to check all the SRA files have been successfully copied over.

cd ~/Wenderski_RNAseq/SRA/SRA_checksum/SRAcheck.log

Make sure ALL files have 'OK' and "Database 'SRRNAME.sra' is consistent" listed. Need to rerun SRRpull.sh script if encountered any errors.

## YOU MUST CHECK THIS - LOOK TO MAKE SURE ALL FILES HAVE 'OK' AND "Database 'SRRNAME.sra' is consistent" LISTED. IF YOU HAVE ANY ERRORS, RERUN.

# Step 2: Concentrate fastq files

This paper sequenced the RNA library for a given sample on 2 separate sequencing runs. The paired-end sequencing data for each sample are stored in consecutive SRA files (i.e. SRR11313882 & SRR11313883 are from the same RNA library and so is SRR11313884 and SRR11313885...etc). These files needs to be contacaneted into a single file for both read 1 and read 2 of each sample.

To do so, run the following script. The new fastq files are stored in a new directory - combined_fastqc under the first occurance of SRA file name for a given sample. For instance, SRR11313882 & SRR11313883 are combined together. The new fastq files will be stored under SRR11313882.

Code: sbatch combine_fastqc.sh

This script runs the following 3 steps:

Code: sbatch FastQCandTrim.sh

