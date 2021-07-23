Last login: Wed Jul 21 11:57:29 on console
Sophias-MacBook-Air:~ sophiagu$ ssh sophiagu@alder.arc.ubc.ca
sophiagu@alder.arc.ubc.ca's password: 
Last login: Mon Jun 28 15:48:27 2021 from host20-115.vpn.ubc.ca
#####################################################################

WELCOME TO ALDER

The University of British Columbia
Djavad Mowafaghian Centre for Brain Health (DMCBH)

#####################################################################

Operated by UBC Advanced Research Computing

Website: https://arc.ubc.ca
Contact: arc.support@ubc.ca

#####################################################################
[sophiagu@alder-login02 ~]$ cd Wenderski_ATACseq
[sophiagu@alder-login02 Wenderski_ATACseq]$ less MakeTSS3kb.sh
[sophiagu@alder-login02 Wenderski_ATACseq]$ less MakeTSS3.out
[sophiagu@alder-login02 Wenderski_ATACseq]$ less FilterBedFiles.sh
[sophiagu@alder-login02 Wenderski_ATACseq]$ less peakfilter.out
[sophiagu@alder-login02 Wenderski_ATACseq]$ less FilterBedFiles.sh


















[sophiagu@alder-login02 Wenderski_ATACseq]$ less FilterBedFiles.sh










[sophiagu@alder-login02 Wenderski_ATACseq]$ less peakfilter.out
[sophiagu@alder-login02 Wenderski_ATACseq]$ less FilterBedFiles.sh



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
