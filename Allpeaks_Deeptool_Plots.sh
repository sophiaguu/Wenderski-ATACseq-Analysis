#!/bin/bash
#
#SBATCH -c 20
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=Allpeaks_deeptools
#SBATCH --output=Allpeaks_deeptools.out
#SBATCH --time=5:00:00


# uses the bigwig files created by UCSCBrowserHOMER.sh instead of the bigwig files in the BigWigs directory
#to make plots for each sample over each set of peak files (peaks from pooled tag directories)

########################################################################################
#plot Homerpeaks_ATAC.Steady.bed
########################################################################################

##########################################################################################

computeMatrix reference-point --referencePoint center -b 500 -a 500 -R homer_peaks/Homerpeaks_ATAC.Steady.bed -S UCSCbrowsertracks/Baseline_ATAC_Repl1.bw UCSCbrowsertracks/Baseline_ATAC_Repl2.bw UCSCbrowsertracks/Baseline_ATAC_Repl3.bw UCSCbrowsertracks/Baseline_ATAC_Repl4.bw UCSCbrowsertracks/Baseline_ATAC_Repl5.bw UCSCbrowsertracks/Knockout_ATAC_Repl1.bw UCSCbrowsertracks/Knockout_ATAC_Repl2.bw UCSCbrowsertracks/Knockout_ATAC_Repl3.bw UCSCbrowsertracks/Knockout_ATAC_Repl4.bw UCSCbrowsertracks/Knockout_ATAC_Repl5.bw UCSCbrowsertracks/Knockout_ATAC_Repl6.bw UCSCbrowsertracks/Knockout_ATAC_Repl7.bw -p 20 -o Deeptools/All_ATACpeaks_baseline.tab.gz --skipZeros --missingDataAsZero --binSize 10 --outFileSortedRegions Deeptools/All_ATACpeaks_baseline_out.bed


##########################################################################################

# plot
plotProfile -m Deeptools/All_ATACpeaks_baseline.tab.gz  --numPlotsPerRow 4 --regionsLabel "steady state ATAC peaks" --plotFileFormat "pdf" -out Deeptools/profile_baselineATACpeaks.pdf --averageType mean --samplesLabel "baseline" "baseline" "baseline" "baseline" "baseline" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" 


# with legend media ymax chosen based on initial graphs
plotHeatmap -m Deeptools/All_ATACpeaks_baseline.tab.gz --regionsLabel "steady state ATAC peaks" --plotFileFormat "pdf" --samplesLabel "baseline" "baseline" "baseline" "baseline" "baseline" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" -out Deeptools/Heatmap.Allpeaks.SteadyState.pdf --averageType mean --perGroup --colorMap bwr --averageTypeSummaryPlot mean --legendLocation upper-right --heatmapWidth 12

##########################################################################################

########################################################################################
#plot Homerpeaks_ATAC.Knockout.bed
########################################################################################

##########################################################################################

computeMatrix reference-point --referencePoint center -b 500 -a 500 -R homer_peaks/Homerpeaks_ATAC.Knockout.bed -S UCSCbrowsertracks/Baseline_ATAC_Repl1.bw UCSCbrowsertracks/Baseline_ATAC_Repl2.bw UCSCbrowsertracks/Baseline_ATAC_Repl3.bw UCSCbrowsertracks/Baseline_ATAC_Repl4.bw UCSCbrowsertracks/Baseline_ATAC_Repl5.bw UCSCbrowsertracks/Knockout_ATAC_Repl1.bw UCSCbrowsertracks/Knockout_ATAC_Repl2.bw UCSCbrowsertracks/Knockout_ATAC_Repl3.bw UCSCbrowsertracks/Knockout_ATAC_Repl4.bw UCSCbrowsertracks/Knockout_ATAC_Repl5.bw UCSCbrowsertracks/Knockout_ATAC_Repl6.bw UCSCbrowsertracks/Knockout_ATAC_Repl7.bw -p 20 -o Deeptools/All_ATACpeaks_Knockout.tab.gz --skipZeros --missingDataAsZero --binSize 10 --outFileSortedRegions Deeptools/All_ATACpeaks_Knockout_out.bed


##########################################################################################

# plot
plotProfile -m Deeptools/All_ATACpeaks_Knockout.tab.gz  --numPlotsPerRow 4 --regionsLabel "Knockout ATAC peaks" --plotFileFormat "pdf" -out Deeptools/profile_KnockoutATACpeaks.pdf --averageType mean --samplesLabel "baseline" "baseline" "baseline" "baseline" "baseline" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" 


# with legend media ymax chosen based on initial graphs
plotHeatmap -m Deeptools/All_ATACpeaks_Knockout.tab.gz --regionsLabel "Knockout ATAC peaks" --plotFileFormat "pdf" --samplesLabel "baseline" "baseline" "baseline" "baseline" "baseline" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" -out Deeptools/Heatmap.Allpeaks.Knockout.pdf --averageType mean --perGroup --colorMap bwr --averageTypeSummaryPlot mean --legendLocation upper-right --heatmapWidth 12

##########################################################################################
