#!/bin/bash
#
#SBATCH -c 1
#SBATCH --mem-per-cpu=2000
#SBATCH --job-name=DiffPeaks
#SBATCH --output=DiffPeaks.out
#SBATCH --time=4:00:00

#######################################################################################
#merges peaks, annotates and calls DE peaks
#######################################################################################
module load samtools/1.4
module load jre/1.8.0_121
module load R/3.6.1

#######################################################################################
mkdir DEpeaks/
#######################################################################################

#Combine Baseline and 12hr peaks into one file for annotation using mergPeaks.

##don't do this if you want to annotate with tag directory. The tag directories doe not have "chr" and all tag counts will be zero.
# Fix chromosome names
# cat homer_peaks/Homerpeaks_ATAC.Steady.txt | awk -F'\t' -vOFS='\t' '{ $2 = "chr" $2 }1' > homer_peaks/Homerpeaks_ATAC.Steady.chr.txt
# 
# cat homer_peaks/Homerpeaks_ATAC.12hrLPS.txt | awk -F'\t' -vOFS='\t' '{ $2 = "chr" $2 }1' > homer_peaks/Homerpeaks_ATAC.12hrLPS.chr.txt
# 
# cat homer_peaks/Homerpeaks_ATAC.24hrLPS.txt | awk -F'\t' -vOFS='\t' '{ $2 = "chr" $2 }1' > homer_peaks/Homerpeaks_ATAC.24hrLPS.chr.txt
# 
# cat homer_peaks/Homerpeaks_ATAC.2weekLPS.txt | awk -F'\t' -vOFS='\t' '{ $2 = "chr" $2 }1' > homer_peaks/Homerpeaks_ATAC.2weekLPS.chr.txt 
#######################################################################################
#baseline vs knockout
#######################################################################################
mergePeaks homer_peaks/Homerpeaks_ATAC.Steady.txt homer_peaks/Homerpeaks_ATAC.Knockout.txt > homer_peaks/Homerpeaks.ATAC.SteadyvsKnockout_all.txt
    
#######################################################################################
#######################################################################################

#Quantify the reads at the initial putative peaks across each of the replicate tag directories using annotatePeaks.pl. 
#http://homer.ucsd.edu/homer/ngs/diffExpression.html. This generate raw counts file from each tag directory for each sample for the merged peaks.

#IMPORTANT: Make sure you remember the order that your experiments and replicates where entered in for generating these commands.  Because experiment names can be cryptic, you will need to specify which experiments are which when running getDiffExpression.pl to assign replicates and conditions.
  
#######################################################################################
#baseline vs knockout
#######################################################################################

annotatePeaks.pl homer_peaks/Homerpeaks.ATAC.SteadyvsKnockout_all.txt mm10 -raw -d TagDirectory/tag_SRR11313930 TagDirectory/tag_SRR11313932 TagDirectory/tag_SRR11313934 TagDirectory/tag_SRR11313936 TagDirectory/tag_SRR11313938 TagDirectory/tag_SRR11313940 TagDirectory/tag_SRR11313942 TagDirectory/tag_SRR11313944 TagDirectory/tag_SRR11313946 TagDirectory/tag_SRR11313948 TagDirectory/tag_SRR11313950 TagDirectory/tag_SRR11313952 > DEpeaks/countTable.baselinevsknockout_ATACpeaks.txt

#######################################################################################
#######################################################################################

#Calls getDiffExpression.pl and ultimately passes these values to the R/Bioconductor package DESeq2 to calculate enrichment values for each peak, returning only those peaks that pass a given fold enrichment (default: 2-fold) and FDR cutoff (default 5%).

#The getDiffExpression.pl program is executed with the following arguments:
#getDiffExpression.pl <raw count file> <group code1> <group code2> [group code3...] [options] > diffOutput.txt

#Provide sample group annotation for each experiment with an argument on the command line (in the same order found in the file, i.e. the same order given to the annotatePeaks.pl command when preparing the raw count file).

#######################################################################################
#baseline vs knockout
#######################################################################################
 
getDiffExpression.pl DEpeaks/countTable.baselinevsknockout_ATACpeaks.txt baseline baseline baseline baseline baseline knockout knockout knockout knockout knockout knockout knockout -simpleNorm > DEpeaks/baselinevsknockout_ATACdiffpeaks.txt
