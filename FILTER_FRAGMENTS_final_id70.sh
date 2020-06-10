#!/bin/bash -l
#SBATCH -J FILTER_FRAGMENTS_final
#SBATCH -o FILTER_FRAGMENTS_final.output
#SBATCH -e FILTER_FRAGMENTS_final.error
#SBATCH --mail-user valentina.peona90@gmail.com
#SBATCH --mail-type=ALL
#SBATCH -t 4:00:00
#SBATCH -A snic2019-3-671
#SBATCH -p core
#SBATCH -n 2

ml bioinfo-tools BEDTools/2.27.1 blast/2.9.0+

INPUTDIR=/home/vpeona/SpecificTE/Intermediate/Blast70/

cd $INPUTDIR

for DIR in $( cat list_dirs_fragments )
do
 cd $DIR
 ls *.final > list_final
 RMSK=/home/vpeona/SpecificTE/Data/RMSK/
 ORIGINAL=$(basename $(pwd) | cut -f1 -d '_').fasta
 NAME=$ORIGINAL.out.bed.filter
 THRESHOLD=300
 
 for FINAL in $( cat list_final )
 do
  OUT=$FINAL.filter
  cut -f1 $FINAL > $FINAL.list
  grep -w -F -f $FINAL.list $RMSK$NAME | awk '{print $0, $3 - $2}' OFS="\t" > $FINAL.list.raw
  awk -v threshold="$THRESHOLD" '$8 >= threshold {print $0}' $FINAL.list.raw > $OUT
 done

 cd $INPUTDIR
 
done
