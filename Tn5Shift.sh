#!/bin/bash
#
#SBATCH -c 16
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=Tn5shift
#SBATCH --output=Tn5shift.out
#SBATCH --time=6:00:00
#######################################################################################
#######################################################################################
# https://github.com/TheJacksonLaboratory/ATAC-seq
#make_atac_seq_shifted_bam_4_shift_sam.sh
#The bam file needs to be adjusted because Tn5 has a 9bp binding site, and it binds in the middle.  
   #        Functionally that means that the DNA had to be accessible at least 4.5bp on either site of the insertion.
# 
#           To my understanding the 4 for positive and 5 for negative was chosen at random, that could be wrong
#           for the negative strand the start position is the 5'-most, which doesn't actually change, it's the 
#           3'-position that changes, and to modify that you only need to change the read sequence and size.
# 
#       If the read is on the positive strand (as determined by the sam flag) 
# 
#               1.  it will add 4 to the start, 
#               2.  and subtract 5 from the partner start
# 
#       if the read is on the negative strand, 
# 
#               1. 5 will subtracted from it's start 
#               2. and 4 added to its mate start.
# 
#        The length and read type will be adjusted in both cases and the read and quality string trimmed appropriately,
#######################################################################################
module load samtools/1.4
module load jre/1.8.0_121 #this loads Java 1.8 working environment
module load R/3.6.1 #picard needs this

for sample in `cat SRR_Acc_List_2.txt`
do

echo ${sample} "starting shifting"

./ATAC_BAM_shifter_gappedAlign.pl aligned/${sample}_dedup.bam aligned/${sample}.shift

#sort
samtools sort aligned/${sample}.shift.bam > aligned/${sample}.shift.sort.bam

#index
samtools index aligned/${sample}.shift.sort.bam


echo ${sample} "completed"


done

