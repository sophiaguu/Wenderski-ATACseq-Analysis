#!/bin/bash
#
#SBATCH -c 20
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=peakfilter
#SBATCH --output=peakfilter.out
#SBATCH --time=1:00:00


# This script performs bedtools intersect to separate out enhancers and promoter from peak files in bed format
#see MakeTSS3kb.sh for script on making TSS input file
#TSS = +/- 3Kb on either side of all UCSC refseq promoters


########################################################################################
#loop through all upset output bed files
########################################################################################

PATH=$PATH:/alder/data/cbh/ciernia-data/pipeline-tools/bedtools2/bin

#!/bin/bash
FILES=/alder/home/sophiagu/shemerATAC/DEpeaks/*.bed
for f in $FILES
do


#extract basename:https://stackoverflow.com/questions/3362920/get-just-the-filename-from-a-path-in-a-bash-script
xbase=${f##*/}
xpref=${xbase%.*}
pref=${xpref}


 echo ${pref} "start"


 #sort
 sort -k1,1 -k2,2n ${f} > DEpeaks/tmp.sorted.bed
 

 
 #write out original entry of a for the overlap with b = regions in peak file that are within +/- 3kb of a promoter

bedtools intersect -a DEpeaks/tmp.sorted.bed -b mm10.promoter.sort.bed -wa > DEpeaks/tmp.3kbpromoterPeaks.bed

sort DEpeaks/tmp.3kbpromoterPeaks.bed | uniq > DEpeaks/${xpref}.3kbpromoterPeaks.bed


#write out original entry of a for not overlap with be = enhancer regions outside of +/- 3kb of a promoter

bedtools intersect -a DEpeaks/tmp.sorted.bed -b mm10.promoter.sort.bed -wa -v > DEpeaks/tmp.EnhancerPeaks.bed

sort DEpeaks/tmp.EnhancerPeaks.bed | uniq > DEpeaks/${xpref}.EnhancerPeaks.bed


rm DEpeaks/tmp.*.bed

 echo ${pref} "done"

done
