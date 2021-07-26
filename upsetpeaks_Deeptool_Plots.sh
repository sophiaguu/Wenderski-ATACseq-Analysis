#!/bin/bash
#
#SBATCH -c 20
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=upsetpeaks_deeptools
#SBATCH --output=upsetpeaks_deeptools.out
#SBATCH --time=5:00:00


# This script is modified from the old script (Geneplots_deeptols.sh) by
# - creating a new directory
# - using the BED file from the DEpeak finding instead of the mm10refseq.bed
# - using the bigwig files created by UCSCBrowserHOMER.sh instead of the bigwig files in the BigWigs directory



########################################################################################
#loop through all upset output bed files
########################################################################################

#!/bin/bash
FILES=/alder/home/sophiagu/shemerATAC/DEpeaks/upset/*.bed
for f in $FILES
do

#m=${echo "$f" | sed -r "s/.+\/(.+)\..+/\1/"}

#extract basename:https://stackoverflow.com/questions/3362920/get-just-the-filename-from-a-path-in-a-bash-script
xbase=${f##*/}
xpref=${xbase%.*}
pref=${xpref}


 echo ${pref} "start"

#remove first line of bed file
sed -i 1d ${f}

awk '{print $2, $3, $4}' ${f} > tmp.bed

#make tab delim
sed -e 's/  */\t/g' <tmp.bed > tmp2.bed

head tmp2.bed

#pull out only bed columns chr, start, stop

 
########################################################################################
#matrix
##########################################################################################

computeMatrix reference-point --referencePoint center -b 500 -a 500 -R tmp2.bed -S UCSCbrowsertracks/Baseline_ATAC_Repl1.bw UCSCbrowsertracks/Baseline_ATAC_Repl2.bw UCSCbrowsertracks/Baseline_ATAC_Repl3.bw UCSCbrowsertracks/Baseline_ATAC_Repl4.bw UCSCbrowsertracks/Baseline_ATAC_Repl5.bw UCSCbrowsertracks/Knockout_ATAC_Repl1.bw UCSCbrowsertracks/Knockout_ATAC_Repl2.bw UCSCbrowsertracks/Knockout_ATAC_Repl3.bw UCSCbrowsertracks/Knockout_ATAC_Repl4.bw UCSCbrowsertracks/Knockout_ATAC_Repl5.bw UCSCbrowsertracks/Knockout_ATAC_Repl6.bw UCSCbrowsertracks/Knockout_ATAC_Repl7.bw -p 20 -o Deeptools/${pref}.tab.gz --skipZeros --missingDataAsZero --binSize 10 --outFileSortedRegions Deeptools/sorted.${pref}.bed


##########################################################################################

# plot
plotProfile -m Deeptools/${pref}.tab.gz --numPlotsPerRow 4 --regionsLabel "upset peaks" --plotFileFormat "pdf" -out Deeptools/profile.${pref}.pdf --averageType mean --samplesLabel "baseline" "baseline" "baseline" "baseline" "baseline" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout"


# with legend media ymax chosen based on initial graphs
plotHeatmap -m Deeptools/${pref}.tab.gz --regionsLabel "upset peaks" --plotFileFormat "pdf" --samplesLabel "baseline" "baseline" "baseline" "baseline" "baseline" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" "knockout" -out Deeptools/Heatmap.${pref}.pdf --averageType mean --perGroup --colorMap bwr --averageTypeSummaryPlot mean --legendLocation upper-right --heatmapWidth 12

 echo ${pref} "done"

done
