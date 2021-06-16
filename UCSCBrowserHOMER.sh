#!/bin/bash
#
#SBATCH -c 12
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=UCSC
#SBATCH --output=HOMERUCSC.out
#SBATCH --time=12:00:00

#######################################################################################
#makeUCSCfile <tag directory-res 10 > -fragLength given -res 10 > UCSCbrowsertracks/
#10bp resolution
#######################################################################################
module load samtools/1.4
module load jre/1.8.0_121
module load R/3.6.1

#######################################################################################
mkdir UCSCbrowsertracks/
echo "making bedGraphs"
#######################################################################################
# ACTL6B
#######################################################################################

#make normalized bedgraphs:
#Steady State
# TagDirectory/tag_SRR11313930
# TagDirectory/tag_SRR11313932
# TagDirectory/tag_SRR11313934
# TagDirectory/tag_SRR11313936
# TagDirectory/tag_SRR11313938

makeUCSCfile TagDirectory/tag_SRR11313930 -fragLength given -name Baseline_ATAC_Repl1 -res 10 > UCSCbrowsertracks/Baseline_ATAC_Repl1.bedGraph

makeUCSCfile TagDirectory/tag_SRR11313932 -fragLength given -name Baseline_ATAC_Repl2 -res 10 > UCSCbrowsertracks/Baseline_ATAC_Repl2.bedGraph

makeUCSCfile TagDirectory/tag_SRR11313934 -fragLength given -name Baseline_ATAC_Repl3 -res 10 > UCSCbrowsertracks/Baseline_ATAC_Repl3.bedGraph

makeUCSCfile TagDirectory/tag_SRR11313936 -fragLength given -name Baseline_ATAC_Repl4 -res 10 > UCSCbrowsertracks/Baseline_ATAC_Repl4.bedGraph

makeUCSCfile TagDirectory/tag_SRR11313938 -fragLength given -name Baseline_ATAC_Repl5 -res 10 > UCSCbrowsertracks/Baseline_ATAC_Repl5.bedGraph

# Knockout ACTL6B -/- samples
# TagDirectory/tag_SRR13182338
# TagDirectory/tag_SRR13182339
# TagDirectory/tag_SRR13182340
# TagDirectory/tag_SRR13182341

makeUCSCfile TagDirectory/tag_SRR11313940 -fragLength given -name Knockout_ATAC_Repl1 -res 10 > UCSCbrowsertracks/Knockout_ATAC_Repl1.bedGraph

makeUCSCfile TagDirectory/tag_SRR11313942 -fragLength given -name Knockout_ATAC_Repl2 -res 10 > UCSCbrowsertracks/Knockout_ATAC_Repl2.bedGraph

makeUCSCfile TagDirectory/tag_SRR11313944 -fragLength given -name Knockout_ATAC_Repl3 -res 10 > UCSCbrowsertracks/Knockout_ATAC_Repl3.bedGraph

makeUCSCfile TagDirectory/tag_SRR11313946 -fragLength given -name Knockout_ATAC_Repl4 -res 10 > UCSCbrowsertracks/Knockout_ATAC_Repl4.bedGraph

makeUCSCfile TagDirectory/tag_SRR11313948 -fragLength given -name Knockout_ATAC_Repl5 -res 10 > UCSCbrowsertracks/Knockout_ATAC_Repl5.bedGraph

makeUCSCfile TagDirectory/tag_SRR11313950 -fragLength given -name Knockout_ATAC_Repl6 -res 10 > UCSCbrowsertracks/Knockout_ATAC_Repl6.bedGraph

makeUCSCfile TagDirectory/tag_SRR11313952 -fragLength given -name Knockout_ATAC_Repl7 -res 10 > UCSCbrowsertracks/Knockout_ATAC_Repl7.bedGraph


#######################################################################################
#pooled tag directories

makeUCSCfile TagDirectory/Pooltag_ATAC_Knockout -fragLength given -name Knockout_ATAC_Repl1 -res 10 > UCSCbrowsertracks/Pooltag_ATAC_Knockout.bedGraph

makeUCSCfile TagDirectory/Pooltag_ATAC_Steady -fragLength given -name Baseline_ATAC_Repl1 -res 10 > UCSCbrowsertracks/Pooltag_ATAC_Steady.bedGraph




#########################################################################################
#######################################################################################
#make into ucsc format
#sed -i 's/old-text/new-text/g' input.txt
#make new file name text file: BedGraphNames.txt
echo "converting to UCSC format"
#######################################################################################


for sample in `cat BedGraphNames.txt`
do

echo ${sample} "starting name fix"

#skip the first line, then add "chr" to each chromosome
sed -i "1n; s/^/chr/" UCSCbrowsertracks/${sample}.bedGraph
sed -i "1n; s/MT/M/g" UCSCbrowsertracks/${sample}.bedGraph

#convert to bigwigs
echo "making bigwig"

#convert to bigwig
#The input bedGraph file must be sort, use the unix sort command:
sort -k1,1 -k2,2n UCSCbrowsertracks/${sample}.bedGraph > UCSCbrowsertracks/${sample}.sort.bedGraph

#remove track line (now at the end of sort files)
sed -i '$d' UCSCbrowsertracks/${sample}.sort.bedGraph

#fix extensions beyond chromosomes > removes entry
#bedClip [options] input.bed chrom.sizes output.bed
bedClip UCSCbrowsertracks/${sample}.sort.bedGraph $mm10chrsizes UCSCbrowsertracks/${sample}.sort2.bedGraph

#bedGraphToBigWig in.bedGraph chrom.sizes out.bw
bedGraphToBigWig UCSCbrowsertracks/${sample}.sort2.bedGraph $mm10chrsizes UCSCbrowsertracks/${sample}.bw

rm UCSCbrowsertracks/${sample}.sort.bedGraph
rm UCSCbrowsertracks/${sample}.bedGraph

echo ${sample} "finished"


done


#zip bedgraphs
gzip UCSCbrowsertracks/*.bedGraph

echo "complete"
