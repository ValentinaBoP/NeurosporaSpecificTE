#!/bin/bash -l
#SBATCH -J FILTER_ALIGNMENT_confirmEmpty
#SBATCH -o FILTER_ALIGNMENT_confirmEmpty.output
#SBATCH -e FILTER_ALIGNMENT_confirmEmpty.error
#SBATCH --mail-user valentina.peona90@gmail.com
#SBATCH --mail-type=ALL
#SBATCH -t 24:00:00
#SBATCH -A snic2019-3-671
#SBATCH -p core
#SBATCH -n 1

ml bioinfo-tools BEDTools/2.27.1 blast/2.9.0+

cd /home/vpeona/SpecificTE/Intermediate/Blast70/

for DIR in $( cat list_dirs )
do
	cd $DIR

	ls *_putativeEmpty.bed > list_empty

	DIR=/home/vpeona/SpecificTE/Data/Genomes/
	REF=$(echo $(pwd) | cut -f7 -d '/' | cut -f2 -d '_').fasta
	ORIGINAL=$(echo $(pwd) | cut -f7 -d '/' | cut -f1 -d '_').fasta

	for EMPTY in $( cat list_empty )
	do
		OUT="${EMPTY%.*}".fasta
		BLAST="$(sed s/_putativeEmpty.fasta/_confirmEmpty.out/g <<<$OUT)"
		bedtools getfasta -fi $DIR$REF -fo $OUT -bed $EMPTY -name
		#makeblastdb -in $DIR$ORIGINAL -out $DIR$ORIGINAL -dbtype nucl -parse_seqids
		blastn -db $DIR$ORIGINAL -query $OUT -task blastn -perc_identity 80 -outfmt '6 qseqid qlen qstart qend sseqid slen sstart send sstrand length pident evalue' -out $BLAST -num_threads 4
	done

	for EMPTY in $( ls *_confirmEmpty.out )
	do
		OUT="${EMPTY%.*}".filter
		FINAL="${EMPTY%.*}".final
		awk '($10/$2) >= 0.8 {print $0}' $EMPTY | awk '$2 >= 800 {print $0}' > $OUT
		awk 'NR==FNR {count[$1]++; next} count[$1]==1' $OUT $OUT > $FINAL
	done

	cd ../
	
done
