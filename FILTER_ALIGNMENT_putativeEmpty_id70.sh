#!/bin/bash -l
#SBATCH -J FILTER_ALIGNMENT_putativeEmpty
#SBATCH -o FILTER_ALIGNMENT_putativeEmpty.output
#SBATCH -e FILTER_ALIGNMENT_putativeEmpty.error
#SBATCH --mail-user valentina.peona90@gmail.com
#SBATCH --mail-type=ALL
#SBATCH -t 10:00:00
#SBATCH -A snic2020-15-44
#SBATCH -p core
#SBATCH -n 1

ml bioinfo-tools BEDTools/2.27.1 R_packages/3.5.0

#cd /home/vpeona/SpecificTE/Code/Blast70/Last
#ls *.output > temp
#sed 's/BLAST_//g' temp | sed 's/_sense_flank[3-5].output//g' | sed 's/_antisense_flank[3-5].output//g' | sort -u > list_dirs

cd /home/vpeona/SpecificTE/Intermediate/Blast70/
ls -d */ > list_dirs

for DIR in $( cat list_dirs )
do
	cd $DIR

	# convert blast into BED format
	ls *_flank[3-5].out > list_blast

	for BLAST in $( cat list_blast )
	do
		BED="${BLAST%.*}".bed
		awk '{print $5, $7, $8, $1, $10, $9, $11, $3, $4}' OFS='\t' $BLAST | sed 's/plus/+/g' | sed 's/minus/-/g' | awk '{if ($2 > $3) {print $1, $3, $2, $4, $5, $6, $7, $8, $9, $10} else {print $0}}' OFS="\t" | bedtools sort -i stdin > $BED
	done

	# find matching flank regions
	ls *_flank5.bed > list_bed5

	for BED5 in $(cat list_bed5 )
	do
		BED3="$(sed s/flank5/flank3/g <<<$BED5)"
		OUT="$(sed s/_flank5.bed/.window/g <<<$BED5)"
		bedtools window -sm -w 50 -a $BED5 -b $BED3 > $OUT
	done

	Rscript --vanilla /proj/sllstore2017101/nobackup/b2011231_nobackup/Valentina/SpecificTE/Code/filterAlignment.R
	
	cd ../
done
