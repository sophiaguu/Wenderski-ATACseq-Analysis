#!/bin/bash
#
#SBATCH -c 20
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=DEpeaks_deeptools
#SBATCH --output=DEpeaks_deeptools.out
#SBATCH --time=5:00:00


# This script is modified from the old script (Geneplots_deeptols.sh) by
# - creating a new directory
# - using the BED file from the DEpeak finding instead of the mm10refseq.bed
# - using the bigwig files created by UCSCBrowserHOMER.sh instead of the bigwig files in the BigWigs directory



########################################################################################
#create new directory to store files
########################################################################################

mkdir DEpeaks_Deeptools

########################################################################################
#plot DEpeaks using DEpeaks
########################################################################################
#baseline vs knockout
##########################################################################################

computeMatrix reference-point --referencePoint center -b 500 -a 500 -R DEpeaks/FDRfiltered.baselinevsknockout_ATACdiffpeaks.bed -S UCSCbrowsertracks/Baseline_ATAC_Repl1.bw UCSCbrowsertracks/Baseline_ATAC_Repl2.bw UCSCbrowsertracks/Baseline_ATAC_Repl3.bw UCSCbrowsertracks/Baseline_ATAC_Repl4.bw UCSCbrowsertracks/Baseline_ATAC_Repl5.bw UCSCbrowsertracks/Knockout_ATAC_Repl1.bw UCSCbrowsertracks/Knockout_ATAC_Repl2.bw UCSCbrowsertracks/Knockout_ATAC_Repl3.bw UCSCbrowsertracks/Knockout_ATAC_Repl4.bw UCSCbrowsertracks/Knockout_ATAC_Repl5.bw UCSCbrowsertracks/Knockout_ATAC_Repl6.bw UCSCbrowsertracks/Knockout_ATAC_Repl7.bw -p 20 -o Deeptools/FDRfiltered.baselinevsknockout_ATACdiffpeaks.tab.gz --skipZeros --missingDataAsZero --binSize 10 --outFileSortedRegions Deeptools/FDRfiltered.baselinevsknockout_ATACdiffpeaks.bed


##########################################################################################

# plot
plotProfile -m Deeptools/FDRfiltered.baselinevsknockout_ATACdiffpeaks.tab.gz  --numPlotsPerRow 4 --regionsLabel "DE ATAC peaks baseline vs knockout" --plotFileFormat "pdf" -out Deeptools/profile_FDRfiltered.baselinevsknockout_ATACdiffpeaks.pdf --averageType mean --samplesLabel "baseline" "baseline" "baseline" "baseline" "baseline" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" 

# with legend media ymax chosen based on initial graphs
plotHeatmap -m Deeptools/FDRfiltered.baselinevsknockout_ATACdiffpeaks.tab.gz --regionsLabel "DE ATAC peaks baseline vs knockout" --plotFileFormat "pdf" --samplesLabel "baseline" "baseline" "baseline" "baseline" "baseline" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" -out Deeptools/Heatmap.FDRfiltered.baselinevsknockout_ATACdiffpeaks.pdf --averageType mean --perGroup --colorMap bwr --averageTypeSummaryPlot mean --legendLocation upper-right --heatmapWidth 12

