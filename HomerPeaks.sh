#!/bin/bash
#
#SBATCH -c 4
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=MakeTags
#SBATCH --output=HOMERTagDir.out
#SBATCH --time=20:00:00
#######################################################################################
#######################################################################################
#HOMER make tag directories
#http://homer.ucsd.edu/homer/ngs/tagDir.html
#one tag directory per sample

#######################################################################################
#make for individual samples
#######################################################################################
module load samtools/1.4
module load jre/1.8.0_121

mkdir TagDirectory/

for sample in `cat SRR_Acc_List_2.txt`
do

echo ${sample} "starting filtering"

#######################################################################################
#make tag directories for each bam file

/alder/data/cbh/ciernia-data/pipeline-tools/.//bin/makeTagDirectory TagDirectory/tag_${sample} aligned/${sample}.shift.sort.bam


##########################################################################################

echo ${sample} "finished filtering"


done

#######################################################################################
#make for pool of all samples

#######################################################################################
#ATAC for steady state baseline samples
#######################################################################################

/alder/data/cbh/ciernia-data/pipeline-tools/.//bin/makeTagDirectory TagDirectory/Pooltag_ATAC_Steady aligned/SRR11313930.shift.sort.bam aligned/SRR11313932.shift.sort.bam aligned/SRR11313934.shift.sort.bam aligned/SRR11313936.shift.sort.bam aligned/SRR11313938.shift.sort.bam



#######################################################################################
#ATAC for knockout ACTL6B -/- samples
#########################################

/alder/data/cbh/ciernia-data/pipeline-tools/.//bin/makeTagDirectory TagDirectory/Pooltag_ATAC_Knockout aligned/SRR11313940.shift.sort.bam aligned/SRR11313942.shift.sort.bam aligned/SRR11313944.shift.sort.bam aligned/SRR11313946.shift.sort.bam aligned/SRR11313948.shift.sort.bam aligned/SRR11313950.shift.sort.bam aligned/SRR11313952.shift.sort.bam


#######################################################################################
#######################################################################################
#http://homer.ucsd.edu/homer/ngs/peaksReplicates.html
#http://homer.ucsd.edu/homer/ngs/peaks.html
#######################################################################################
#peak calling based on Gosselin et al 2017 ATACseq
#########################################


mkdir homer_peaks


#Peaks were then called on the pooled tags using
#HOMER’s “findPeaks” command with the following parameters: “-style factor -size 200 -
#minDist 200” where the “-tbp” parameter was set to the number of replicates in the pool.

#findPeaks -style factor -size 200 -minDist 200 -tbp 4

#######################################################################################
#ATAC for steady state baseline samples
#######################################################################################

/alder/data/cbh/ciernia-data/pipeline-tools/.//bin/findPeaks TagDirectory/Pooltag_ATAC_Steady -style factor -size 200 -minDist 200 -tbp 8 -o homer_peaks/Homerpeaks_ATAC.Steady.txt


#######################################################################################
#ATAC for knockout ACTL6B -/- samples
#########################################

/alder/data/cbh/ciernia-data/pipeline-tools/.//bin/findPeaks TagDirectory/Pooltag_ATAC_Knockout -style factor -size 200 -minDist 200 -tbp 4 -o homer_peaks/Homerpeaks_ATAC.Knockout.txt


#######################################################################################
#######################################################################################
#convert to bed
#using modified pos2bedmod.pl that keeps peak information
#######################################################################################
#######################################################################################

#######################################################################################
#ATAC for steady state baseline samples
#######################################################################################

grep -v '^#' homer_peaks/Homerpeaks_ATAC.Steady.txt > homer_peaks/tmp.txt
   
    perl pos2bedmod.pl homer_peaks/tmp.txt > homer_peaks/tmp.bed
   
    sed 's/^/chr/' homer_peaks/tmp.bed > homer_peaks/Homerpeaks_ATAC.Steady.bed
   
    rm homer_peaks/tmp*



#######################################################################################
#ATAC for knockout ACTL6B -/- samples
#######################################################################################

grep -v '^#' homer_peaks/Homerpeaks_Knockout.txt > homer_peaks/tmp.txt
   
    perl pos2bedmod.pl homer_peaks/tmp.txt > homer_peaks/tmp.bed
   
    sed 's/^/chr/' homer_peaks/tmp.bed > homer_peaks/Homerpeaks_ATAC.Knockout.bed
   
    rm homer_peaks/tmp*


#cat peaks.txt | awk -F'\t' -vOFS='\t' '{ $2 = "chr" $2 }1' > peaks_chr.txt


