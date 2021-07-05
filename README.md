# Wenderski-ATACseq-Analysis

# The output for this entire analysis: https://github.com/sophiaguu/Wenderski-ATACseq-Output

Processing ATAC-seq PE files sourced from the Crabtree Lab: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7211998/.

The ATACseq dataset is downloaded from published PE ATAC-seq files from GEO Accession (https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE147056) and processing them for QC, aligning and analysis in Rstudio. The analysis is setup to run on the DMCBH Alder computing cluster using bash scripts.

# Step 1: Fetching Data from GEO

We will be analyzing ATACseq dataset from the following paper:https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7211998/.

The data is stored in NCBI GEO as SRR files which are highly compressed files that can be converted to fastq files using SRA Toolkit: https://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP252982&o=acc_s%3Aa.

To download a text file of SRR files, use the Run Select function. Navigate to the bottom of the page and select all the ATAC-seq data. Be careful to not select any RNA-seq data. Download "Accession List".

### Make a directory for the experiment in your home directory

```
cd ~/ && mkdir Wenderski_ATACseq
```

Make a copy of the SRR_Acc.List.txt file in your home directory.

``` 
cd ~/Wenderski_ATACseq
nano SRR_Acc_List.txt 
```

### Run the SRRpull.sh script

The script is setup to run from the experiment directory inside home directory.

It makes a SRA directory in the experiment directory and uses a loop to pull each SRR file in SRR_Acc_List.txt using prefetch.

We added --split to fastq-dump command to get R1 and R2 fastq for each SRR entry because the files are PE.

Make a SRRpull.sh script in the experiment directory and run the script as sbatch submission to Alder.

``` 
sbatch SRRpull.sh 
```

Check to see if the script is running.

``` 
squeue 
```

Can also check to see if SRAfetch is running properly by checking the contents of the experiment directory to see if a SRAfetch.out has been generated.

``` 
less SRAfetch.out 
```

Press q to quit an output log. Output logs are also be used to monitor the progress of SRAfetch.

Once the script has finished running, make sure to check all the SRA files have been successfully copied over.

cd ~/Wenderski_RNAseq/SRA/SRA_checksum/SRAcheck.log

Make sure ALL files have 'OK' and "Database 'SRRNAME.sra' is consistent" listed. Need to rerun SRRpull.sh script if encountered any errors.

## YOU MUST CHECK THIS - LOOK TO MAKE SURE ALL FILES HAVE 'OK' AND "Database 'SRRNAME.sra' is consistent" LISTED. IF YOU HAVE ANY ERRORS, RERUN.

# Step 2: Concentrate fastq files

This paper sequenced the RNA library for a given sample on 2 separate sequencing runs. The paired-end sequencing data for each sample are stored in consecutive SRA files (i.e. SRR11313882 & SRR11313883 are from the same RNA library and so is SRR11313884 and SRR11313885...etc). These files needs to be contacaneted into a single file for both read 1 and read 2 of each sample.

To do so, run the following script. The new fastq files are stored in a new directory - combined_fastqc under the first occurance of SRA file name for a given sample. For instance, SRR11313882 & SRR11313883 are combined together. The new fastq files will be stored under SRR11313882.

``` 
sbatch combine_fastqc.sh 
```

We have combined all the fastq files from the same sample into one fastq file, so our SRR_Acc_List.txt also needs to be updated for downstream scripts that references the SRR_Acc_List.txt file.

We will first ensure SRR_Acc_List.txt is sorted and make a copy of it.

``` 
sort -o SRR_Acc_List.txt SRR_Acc_List.txt 
cp SRR_Acc_List.txt SRR_Acc_List_2.txt 
```

Then we'll use the ex (text editor) command to match every line inside the file and deleting the next line.

``` 
ex SRR_Acc_List_2.txt <<\EX
:g/$/+d
:wq!
EX 
```

Make sure to double check the txt file to ensure it contains every other SRA file name.

```
cat SRR_Acc_List_2.txt 
```

This script runs the following 3 steps:

``` 
sbatch FastQCandTrim.sh 
```

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

``` 
less $ADAPTERS/TruSeq3-PE.fa 
```

# Step 5: Repeat QC on post trim files

Repeat the QC on the post trim files and compare the output to the pretrim.

# Step 6: QC of the Fastq Files: Contamination Screening

FastQ Screen is a simple application which allows you to search a large sequence dataset against a panel of different genomes to determine from where the sequences in your data originate. The program generates both text and graphical output to inform you what proportion of your library was able to map, either uniquely or to more than one location, against each of your specified reference genomes. The user should therefore be able to identify a clean sequencing experiment in which the overwhelming majority of reads are probably derived from a single genomic origin.

## setup of the Fastq_screen indexes (bowtie2)

http://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/_build/html/index.html#requirements-summary

This was already done for you, but in case you need to make changes this is how it was setup.

Bowtie2 index files were downloaded to /alder/data/cbh/ciernia-data/pipeline-tools/FastQ-Screen-0.14.1/FastQ_Screen_Genomes with the command run from inside /alder/data/cbh/ciernia-data/pipeline-tools/

``` 
fastq_screen --get_genomes 
```

The fastq_screen.conf file is then copied from the FastQ_Screen_Genomes folder to /alder/data/cbh/ciernia-data/pipeline-tools/FastQ-Screen-0.14.1

We then need to edit the fastq_screen.conf file using nano to tell the program where to find bowtie2. Uncomment the BOWTIE2 path line so that it says:

BOWTIE2 /alder/data/cbh/ciernia-data/pipeline-tools/bowtie2-2.4.1-linux-x86_64/bowtie2

From your experiment directory run the script to check your trimmed fastq files

``` 
sbatch Fastqscreen.sh 
```

The output is found in output/FastqScreen_multiqc_report.html

# Step 7: Align to mm10 genome using Bowtie2

We now will align the trimmed fastq files to the mm10 genome using bowtie2. Bowtie2 needs to know where the index files are located. We specified this in our bash_profile. Check the location:

``` 
ls $BT2_MM10 
```

Run the script to align. This takes significant time and memory. Output logs are placed in output/bowtielogs

``` 
sbatch Bowtie2alignment.sh 
```

Check the multiqc output to look at alignment rates: bowtie2_multiqc_report.html

# Step 8: Filter aligned files

We need to convert sam files to bam and filter to remove PCR duplicates, remove unmapped reads and secondary alignments (multi-mappers), and remove unpaired reads
We use samtools to convert sam to bam and then samtools fixmate to remove unmapped reads and 2ndary alignments.
We then remove PCR duplicates using -F 0x400 and -f 0x2 to keep only propperly paired reads
We then indext the reads and collect additional QC metrics using picard tools and samtools flagstat
QC meterics are then collected into one report using multiqc.

Run the script:

``` 
sbatch SamtoolsFiltering.sh 
```

Check the multiqc: sam_multiqc_report.html

# Step 9: Shift for Tn5 cut sites: https://github.com/TheJacksonLaboratory/ATAC-seq

From Asli Uyar, PhD "The bam file needs to be adjusted because Tn5 has a 9bp binding site, and it binds in the middle.
Functionally that means that the DNA had to be accessible at least 4.5bp on either site of the insertion.
   
Example of how a BAM file will be altered

Original: HWI-ST374:226:C24HPACXX:4:2214:15928:96004 99 chrI 427 255 101M = 479 153 HWI-ST374:226:C24HPACXX:4:2214:15928:96004 147 chrI 479 255 101M = 427 -153

Altered: HWI-ST374:226:C24HPACXX:4:2214:15928:96004 99 chrI 431 255 97M = 474 144 HWI-ST374:226:C24HPACXX:4:2214:15928:96004 147 chrI 479 255 96M = 431 -144

``` 
sbatch Tn5Shift.sh 
```

This calls to: ATAC_BAM_shifter_gappedAlign.pl makes sample.shift.bam out put and .bai file

# Step 10: QC with Deeptools

https://deeptools.readthedocs.io/en/develop/content/example_usage.html#how-we-use-deeptools-for-chip-seq-analyses

1. Correlation between BAM files using multiBamSummary and plotCorrelation Together, these two modules perform a very basic test to see whether the sequenced and aligned reads meet your expectations. We use this check to assess reproducibility - either between replicates and/or between different experiments that might have used the same antibody or the same cell type, etc. For instance, replicates should correlate better than differently treated samples.
The coverage calculation is done for consecutive bins of equal size (10 kilobases by default). This mode is useful to assess the genome-wide similarity of BAM files. The bin size and distance between bins can be adjusted.

Exclude black list regions: A BED or GTF file containing regions that should be excluded from all analyses. Currently this works by rejecting genomic chunks that happen to overlap an entry. Consequently, for BAM files, if a read partially overlaps a blacklisted region or a fragment spans over it, then the read/fragment might still be considered. Please note that you should adjust the effective genome size, if relevant.

For PE reads are centered with respect to the fragment length. For paired-end data, the read is centered at the fragment length defined by the two ends of the fragment. For single-end data, the given fragment length is used. This option is useful to get a sharper signal around enriched regions.

Plot the correlation between samples as either a PCA or a Correlation Plot.

2. Check Fragment Sizes (bamPEFragmentSize) For paired-end samples, we often additionally check whether the fragment sizes are more or less what we would expected based on the library preparation.

``` 
sbatch DeepToolsQC.sh 
```

# Step 11: Peak Calling with HOMER

1. Make tag directories for each sample and for the pool of all samples in the same condition (ie. all 12hr LPS replicates).

2. Use the pooled the target tag directories and perform an initial peak identification using findPeaks. Pooling the experiments is generally more sensitive than trying to merge the individual peak files coming from each experiment. Use parameters from Gosselin et al 2017: findPeaks -style factor -size 200 -minDist 200 -tbp 4 where -tbp is the number of replicates in the pooled tag directory.

3. Also make bed files for the pooled peaks using a modified pos2bedmod.pl that keeps peak information.

``` 
sbatch HomerPeaks.sh 
```

# Step 12: Make UCSC genome browser track files

Make bedgraph and Bigwig files for each sample replicate and the pooled tag directories at a resolution of 10bp bins using makeUCSCfile. Normalized to the 1e7 total tags and use the given fragment length. Then we need to make several corrections to the chromosome names. We aligned to ensembl whic does not have "chr" as part of the chromosome name. UCSC requires this to load into the browser. We manually add this and fix the mitochondrial chromosome from M to MT:

sed -i "1n; s/^/chr/" UCSCbrowsertracks/${sample}.bedGraph sed -i "1n; s/MT/M/g" UCSCbrowsertracks/${sample}.bedGraph

After fixing the names, we sort, remove the track line and fix extensions beyond chromosomes using bedclip. Then we convert from bedGraph to bigwig. Bigwig files can be loaded onto a webserver to build a track hub for viewing in UCSC. Zipped bedGraph files (if they are small enough) can be loaded directly into UCSC through the online portal.

``` 
sbatch UCSCBrowserHOMER.sh 
```

# The bigwig files can be uploaded into UCSC Browser Genome for viewing.

http://genome.ucsc.edu/goldenPath/help/hgTrackHubHelp.html#Hosting
This allows for actual viewing of the bigwig files. 

http://genome.ucsc.edu/goldenPath/help/bigWig.html
This is how you can upload your bigwig files. Use a website such as https://de.cyverse.org/ Discovery Environment to upload your bigwig files into a public link on the internet, which can then be uploaded into Custom Tracks on UCSC Browser Genome. 

# Step 13: QC all peaks with Deeptools

Use deeptools to make plots over the called peask for each sample and condition. +/- 500 bp surrounding each peak.

``` 
sbatch Allpeaks_Deeptool_Plots.sh 
```

# Step 14: Differential Peak Analysis with HOMER

1. Merge peaks together for the comparison of interest using mergePeaks

2. Quantify the reads in the mergePeaks file across each of the individual sample tag directories using annotatePeaks.pl. http://homer.ucsd.edu/homer/ngs/diffExpression.html. This generate raw counts file from each tag directory for each sample for the merged peaks.

3. Call getDiffExpression.pl and ultimately passes these values to the R/Bioconductor package DESeq2 to calculate enrichment values for each peak, returning only those peaks that pass a given fold enrichment (default: 2-fold) and FDR cutoff (default 5%).

IMPORTANT: Make sure you remember the order that your experiments and replicates where entered in for generating these commands. Because experiment names can be cryptic, you will need to specify which experiments are which when running getDiffExpression.pl to assign replicates and conditions.

Provide sample group annotation for each experiment with an argument on the command line (in the same order found in the file, i.e. the same order given to the annotatePeaks.pl command when preparing the raw count file).

One key difference in the use of DESeq2 for finding significant peaks is that HOMER will force the normalization factors for each experiment to reflect the total number of mapped tags per experiment during the DESeq2 calculation. By default, DESeq2 (and DESeq/edgeR) will normalize the read counts in the input table to be the same (i.e. think quantile normalization), but in this case "input" or IgG experiments would likely have significantly less reads in putative peaks than the target experiments, so it is important to adjust the normalization factors. Unfortunately, edgeR does not support this adjustment so it is not possible to use edgeR to calculate the statistics for differential peak finding (vs. input).

By default it looks for peaks that have 4-fold more tags (sequencing-depth independent) and a cumulative Poisson p-value less than 0.0001 (sequencing-depth dependent). These parameters are adjustable with ("-F <#>", and "-P <#>"). By specifying "-same", peaks that are similar between the two tag directories will be returned instead of differential peaks. One caveat is that it is a good idea to set the size of the region used to search for reads to be larger than the actual peaks (i.e. +100 bp relative to the peak size) to avoid problems that arise from experiments with different fragment lengths, etc.

http://homer.ucsd.edu/homer/ngs/mergePeaks.html

NOTE about normalization for this step: The read counts are normalized to the total number of reads found in their tag directories (no fancy normalization is assumed for this analysis). However, to be conservative with the Poisson calculations, the experiment with the largest number of reads is normalized such that it contains the same number of reads as the smaller experiment. As a result, only one of the directories - either the target directory ("Total Tags", column 8) or the background directory ("Background Tags", Column 9), will have integer counts and the other is likely to contain fractional counts.

-simpleNorm (Normalize to experiment totals, i.e. basic normalization)

``` 
sbatch DifferentialPeaks.sh 
```

# Step 15: Make Deeplots heatmap and profile over TSS and DE peaks

These plots use Deeptools computeMatrix, plotHeatmap and plotProfile to plot the average signal over specific regions specified in a bed file. We will be using the read-depth normalized bigwig files generated from running the UCSCBrowserHOMER.sh script.

# TSS Heatmap Plots

Plot Normalized signal over the TSS with computeMatrix, plotHeatmap and plotProfile. You first need the coordinates of all the mm10 genes in bed format. To get these go to the UCSC genome browser and select mm10. Go to the table browser and download a bed file for the gene body. Load the bed file into your experiment folder on Alder or use the one already available: mm10.refseq.bed Plot 1kb upstream and 500bp downstream of each TSS in mm10. Plots profiles (mean) and heatmap (each row is a gene in teh mm10.refseq.bed). https://deeptools.readthedocs.io/en/develop/content/tools/computeMatrix.html

``` 
sbatch Geneplots_deeptools.sh 
```

# DE Peaks Heatmap Plots

Plot Normalized signal over each set of DE peaks with computeMatrix, plotHeatmap and plotProfile. You first need to convert the _diffpeaksOutput.txt files from the getDiffExpression.pl script to bed files. This requires making some formtting changes, sorting and filtering for significant peaks using unix commands. A detailed description of each step is found within the script. This script produces an output bed file for regions that pass an FDR<0.05.

IMPORTANT: see notes in script for how to find and set the last column in the DE peaks output file in order to filter correctly on the FDR adjusted pvalue.

``` 
sbatch Convert_DEpeaks_to_bed.sh 
```

Plot 500bp upstream and 500bp downstream of each DE region. Plots profiles (mean) and heatmap (each row is a differential region). https://deeptools.readthedocs.io/en/develop/content/tools/computeMatrix.html

``` 
sbatch DEpeaks_Deeptool_Plots.sh 
```

# Step 16a: Repeat differential analysis on enhancer regions or promoter regions only - Approach 1

## 1. download TSS start sites and add 3kb to either side

Go to mm10 UCSC genome browser > Table Browser: https://genome.ucsc.edu/cgi-bin/hgTables?hgsid=984798937_SZsK0ReMotdHw4voBY99gZp26FqS Select UCSC RefSeq genes Select Bed format ouptufile: mm10.refseq.TSS.bed

#https://www.biostars.org/p/158712/#158719 #take all mm10 genes and add 3kb up and downstream #takes into account strand information upstream=3000

downstream=3000

cat mm10.refseq.bed | awk '{ if ($6 == "+") { print $1,$2-'$upstream', $2+'$downstream', $4, $5, $6,$7,$8,$9,$10,$11,$12 } else if ($6 == "-") { print $1, $3-'$upstream', $3+'$downstream', $4,$5,$6,$7,$8,$9,$10,$11,$12 }}' > mm10.promoter.bed

``` 
./MakeTSS3kb.sh
```

## 2. separate DE peak files by those within 3kb of a TSS = promoter vs. those outside of 3kb of a TSS = enhancer

Note: If you don't have bedtools installed: https://bedtools.readthedocs.io/en/latest/content/installation.html

It is currently in the /alder/data/cbh/ciernia-data/pipeline-tools/bedtools2/bin so add this to your profile to access directly as PATH=$PATH:/alder/data/cbh/ciernia-data/pipeline-tools/bedtools2/bin and source the profile

Use bedtools intersect: https://bedtools.readthedocs.io/en/latest/content/tools/intersect.html

```
sbatch FilterBedFiles.sh
```

## 3. plot with upset and deeptools

``` 
sbatch EnhancerPromoterUpsetRplots.sh
```

Makes heatmaps and profiles over each bed file output from upset plot

```
sbatch upsetpeaks_Deeptool_Plots.sh
```
