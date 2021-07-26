#!/bin/bash
#
#SBATCH -c 20
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=TSSplot
#SBATCH --output=TSSplot.out
#SBATCH --time=5:00:00


########################################################################################
#plot for signal over TSS regions of mouse genes
########################################################################################


computeMatrix reference-point --referencePoint TSS -b 1000 -a 500 -R mm10.refseq.bed -S UCSCbrowsertracks/Baseline_ATAC_Repl1.bw UCSCbrowsertracks/Baseline_ATAC_Repl2.bw UCSCbrowsertracks/Baseline_ATAC_Repl3.bw UCSCbrowsertracks/Baseline_ATAC_Repl4.bw UCSCbrowsertracks/Baseline_ATAC_Repl5.bw UCSCbrowsertracks/Knockout_ATAC_Repl1.bw UCSCbrowsertracks/Knockout_ATAC_Repl2.bw UCSCbrowsertracks/Knockout_ATAC_Repl3.bw UCSCbrowsertracks/Knockout_ATAC_Repl4.bw UCSCbrowsertracks/Knockout_ATAC_Repl5.bw UCSCbrowsertracks/Knockout_ATAC_Repl6.bw UCSCbrowsertracks/Knockout_ATAC_Repl7.bw -p 20 -o Deeptools/mouseTSS.ATAC.tab.gz --skipZeros --missingDataAsZero --binSize 10 --outFileSortedRegions Deeptools/mouseTSS.ATAC_out.bed


##########################################################################################

# plot
plotProfile -m Deeptools/mouseTSS.ATAC.tab.gz --numPlotsPerRow 4 --regionsLabel "Mouse TSS ATAC peaks" --plotFileFormat "pdf" -out Deeptools/profile_mouseTSS.ATAC.pdf --averageType mean --samplesLabel "baseline" "baseline" "baseline" "baseline" "baseline" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout"


# with legend media ymax chosen based on initial graphs
plotHeatmap -m Deeptools/mouseTSS.ATAC.tab.gz --regionsLabel "Mouse TSS ATAC peaks" --plotFileFormat "pdf" --samplesLabel "baseline" "baseline" "baseline" "baseline" "baseline" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" -out Deeptools/Heatmap.MouseTSS.ATAC.pdf --averageType mean --perGroup --colorMap bwr --averageTypeSummaryPlot mean --legendLocation upper-right --heatmapWidth 12

