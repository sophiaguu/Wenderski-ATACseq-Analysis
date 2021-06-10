#!/bin/bash
#
#SBATCH -c 20
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=BamSum
#SBATCH --output=BamSummary.out
#SBATCH --time=10:00:00

#######################################################################################
#bam summary 
#######################################################################################
mkdir Deeptools

#ATAC Seq all data
multiBamSummary bins --bamfiles aligned/SRR11313930.shift.sort.bam aligned/SRR11313932.shift.sort.bam aligned/SRR11313934.shift.sort.bam aligned/SRR11313936.shift.sort.bam aligned/SRR11313938.shift.sort.bam aligned/SRR11313940.shift.sort.bam aligned/SRR11313942.shift.sort.bam aligned/SRR11313944.shift.sort.bam aligned/SRR11313946.shift.sort.bam aligned/SRR11313948.shift.sort.bam aligned/SRR11313950.shift.sort.bam aligned/SRR11313952.shift.sort.bam --labels baseline baseline baseline baseline baseline knockout knockout knockout knockout knockout knockout knockout -o Deeptools/ATAC_BamSum10kbbins.npz --blackListFileName $BL/mm10.blacklist.bed -p 20 --centerReads


 #Plot the correlation between samples as either a PCA or a Correlation Plot:

     
plotPCA -in Deeptools/ATAC_BamSum10kbbins.npz -o Deeptools/PCA_ATAC10kbins.pdf -T "PCA of Sequencing Depth Normalized Read Counts" --plotHeight 7 --plotWidth 9


plotCorrelation -in Deeptools/ATAC_BamSum10kbbins.npz --corMethod spearman --skipZeros --plotTitle "Spearman Correlation of Sequencing Depth Normalized Read Counts" --whatToPlot heatmap --colorMap RdYlBu --plotNumbers -o Deeptools/SpearmanCorr_ATAC10kbins.pdf    

#######################################################################################
#PE fragment sizes
#This tool calculates the fragment sizes for read pairs given a BAM file from paired-end sequencing.Several regions are sampled depending on the size of the genome and number of processors to estimate thesummary statistics on the fragment lengths. Properly paired reads are preferred for computation, i.e., it will only use discordant pairs if no concordant alignments overlap with a given region. The default setting simply prints the summary statistics to the screen.

#######################################################################################

#######################################################################################
#ATAC for steady state baseline samples
#######################################################################################

bamPEFragmentSize --bamfiles aligned/SRR11313930.shift.sort.bam aligned/SRR11313932.shift.sort.bam aligned/SRR11313934.shift.sort.bam aligned/SRR11313936.shift.sort.bam aligned/SRR11313938.shift.sort.bam --samplesLabel baseline baseline baseline baseline baseline --histogram Deeptools/ATAC.baseline_PEfragsize.pdf --blackListFileName $BL/mm10.blacklist.bed -p 20 --plotFileFormat pdf



#######################################################################################
#ATAC for knockout ACTL6B -/- samples
#########################################

bamPEFragmentSize --bamfiles aligned/SRR11313940.shift.sort.bam aligned/SRR11313942.shift.sort.bam aligned/SRR11313944.shift.sort.bam aligned/SRR11313946.shift.sort.bam aligned/SRR11313948.shift.sort.bam aligned/SRR11313950.shift.sort.bam aligned/SRR11313952.shift.sort.bam --samplesLabel knockout knockout knockout knockout knockout knockout knockout --histogram Deeptools/ATAC.Knockout_PEfragsize.pdf --blackListFileName $BL/mm10.blacklist.bed -p 20 --plotFileFormat pdf


