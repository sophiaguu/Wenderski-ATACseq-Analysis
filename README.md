# Wenderski-ATACseq-Analysis

Processing ATAC-seq PE files sourced from the Crabtree Lab: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7211998/.

The ATACseq dataset is downloaded from published PE ATAC-seq files from GEO Accession (https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE147056) and processing them for QC, aligning and analysis in Rstudio. The analysis is setup to run on the DMCBH Alder computing cluster using bash scripts.

# Step 1: Fetching Data from GEO

We will be analyzing ATACseq dataset from the following paper:https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7211998/.

The data is stored in NCBI GEO as SRR files which are highly compressed files that can be converted to fastq files using SRA Toolkit: https://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP252982&o=acc_s%3Aa.

To download a text file of SRR files, use the Run Select function. Navigate to the bottom of the page and select all the ATAC-seq data. Be careful to not select any RNA-seq data. Download "Accession List".

### Make a directory for the experiment in your home directory

```cd ~/ && mkdir Wenderski_ATACseq```

Make a copy of the SRR_Acc.List.txt file in your home directory.

``` cd ~/Wenderski_ATACseq ```
``` nano SRR_Acc_List.txt ```

### Run the SRRpull.sh script

The script is setup to run from the experiment directory inside home directory.

It makes a SRA directory in the experiment directory and uses a loop to pull each SRR file in SRR_Acc_List.txt using prefetch.

We added --split to fastq-dump command to get R1 and R2 fastq for each SRR entry because the files are PE.

Make a SRRpull.sh script in the experiment directory and run the script as sbatch submission to Alder.

``` sbatch SRRpull.sh ```

Check to see if the script is running.

``` squeue ```

Can also check to see if SRAfetch is running properly by checking the contents of the experiment directory to see if a SRAfetch.out has been generated.

``` less SRAfetch.out ```

Press q to quit an output log. Output logs are also be used to monitor the progress of SRAfetch.

Once the script has finished running, make sure to check all the SRA files have been successfully copied over.

cd ~/Wenderski_RNAseq/SRA/SRA_checksum/SRAcheck.log

Make sure ALL files have 'OK' and "Database 'SRRNAME.sra' is consistent" listed. Need to rerun SRRpull.sh script if encountered any errors.

## YOU MUST CHECK THIS - LOOK TO MAKE SURE ALL FILES HAVE 'OK' AND "Database 'SRRNAME.sra' is consistent" LISTED. IF YOU HAVE ANY ERRORS, RERUN.

# Step 2: Concentrate fastq files

This paper sequenced the RNA library for a given sample on 2 separate sequencing runs. The paired-end sequencing data for each sample are stored in consecutive SRA files (i.e. SRR11313882 & SRR11313883 are from the same RNA library and so is SRR11313884 and SRR11313885...etc). These files needs to be contacaneted into a single file for both read 1 and read 2 of each sample.

To do so, run the following script. The new fastq files are stored in a new directory - combined_fastqc under the first occurance of SRA file name for a given sample. For instance, SRR11313882 & SRR11313883 are combined together. The new fastq files will be stored under SRR11313882.

``` sbatch combine_fastqc.sh ```

This script runs the following 3 steps:

``` sbatch FastQCandTrim.sh ```

# Step 3: QC of the Fastq Files

We need to check the quality of the fastq files both before and after trimming. We use FastQC from https://www.bioinformatics.babraham.ac.uk/projects/fastqc/ Look at their tutorials to interpret the output files

The pretrim_fastqc.sh script makes an output file and a subfolder for pretrim .html files (one for each fastq file). We have to check both the foreward (R1) and reverse (R2) reads.

The script loops through each fastq and generates a quality resport for each fastq in the /alder/data/cbh/ciernia-data/HDAC1_2_ChIPseq/SRA/ folder.

It then combines the reports into one easy to read output using multiqc: PretrimFastQC_multiqc_report.html PreTrimFastqc.out output log is also generated.

Check the PretrimFastQC_multiqc_report.html to help inform your trimming

# Step 4: Trimming fastq files

We need to remove adapters and poor quality reads before aligning.
Trimmomatic will look for seed matches of 16 bases with 2 mismatches allowed and will then extend and clip if a score of 30 for PE or 10 for SE is reached (~17 base match)
The minimum adapter length is 8 bases
T = keeps both reads even if only one passes criteria
Trims low quality bases at leading and trailing end if quality score < 15
Sliding window: scans in a 4 base window, cuts when the average quality drops below 15
Log outputs number of input reads, trimmed, and surviving reads in trim_log_samplename

It uses the file TruSeq3-PE.fa (comes with Trimmomatic download).
The program needs to know where this is stored. We set the path to thies file in the bash_profile with $ADAPTERS
To check the contents of the file:

``` less $ADAPTERS/TruSeq3-PE.fa ```

# Step 5: Repeat QC on post trim files

Repeat the QC on the post trim files and compare the output to the pretrim.

# Step 6: QC of the Fastq Files: Contamination Screening

FastQ Screen is a simple application which allows you to search a large sequence dataset against a panel of different genomes to determine from where the sequences in your data originate. The program generates both text and graphical output to inform you what proportion of your library was able to map, either uniquely or to more than one location, against each of your specified reference genomes. The user should therefore be able to identify a clean sequencing experiment in which the overwhelming majority of reads are probably derived from a single genomic origin.

## setup of the Fastq_screen indexes (bowtie2)

http://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/_build/html/index.html#requirements-summary

This was already done for you, but in case you need to make changes this is how it was setup.

Bowtie2 index files were downloaded to /alder/data/cbh/ciernia-data/pipeline-tools/FastQ-Screen-0.14.1/FastQ_Screen_Genomes with the command run from inside /alder/data/cbh/ciernia-data/pipeline-tools/

``` fastq_screen --get_genomes ```

The fastq_screen.conf file is then copied from the FastQ_Screen_Genomes folder to /alder/data/cbh/ciernia-data/pipeline-tools/FastQ-Screen-0.14.1

We then need to edit the fastq_screen.conf file using nano to tell the program where to find bowtie2. Uncomment the BOWTIE2 path line so that it says:

BOWTIE2 /alder/data/cbh/ciernia-data/pipeline-tools/bowtie2-2.4.1-linux-x86_64/bowtie2

From your experiment directory run the script to check your trimmed fastq files

``` sbatch Fastqscreen.sh ```

The output is found in output/FastqScreen_multiqc_report.html
