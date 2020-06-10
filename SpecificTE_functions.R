getCombinations = function(genomes, directory, id){
	
	require(tidyr)

	# get all the combinations
	crosses = crossing(genomes, genomes)
	
	# delete crosses between the same genome
	boo = crosses[,1] == crosses[,2]
	crosses = crosses[!boo,]
	
	for(i in 1:nrow(crosses)){
	
		target = crosses[i,1]
		query = crosses[i,2]
		folder = paste(directory, query, "_", target, sep = "")
		
		job = paste("BLAST", query, target, "antisense_flank3", sep = "_")
		writeBlastJobs(target = target, query = query, job = job, sense = "antisense", flank = "flank3", folder = folder, id = id)
		job = paste("BLAST", query, target, "sense_flank3", sep = "_")
		writeBlastJobs(target = target, query = query, job = job, sense = "sense", flank = "flank3", folder = folder, id = id)
		job = paste("BLAST", query, target, "antisense_flank5", sep = "_")
		writeBlastJobs(target = target, query = query, job = job, sense = "antisense", flank = "flank5", folder = folder, id = id)
		job = paste("BLAST", query, target, "sense_flank5", sep = "_")
		writeBlastJobs(target = target, query = query, job = job, sense = "sense", flank = "flank5", folder = folder, id = id)
	
	}

}

writeBlastJobs = function(target, query, job, folder, sense, flank, id){

	target = paste("/proj/sllstore2017101/nobackup/b2011231_nobackup/Valentina/SpecificTE/Data/Genomes/", target, ".fasta", sep = "")
	query = paste("/proj/sllstore2017101/nobackup/b2011231_nobackup/Valentina/SpecificTE/Data/Flanks/", query, ".fasta.out.bed.", sense, ".", flank, ".fasta", sep = "")
	sink(paste(job, ".sh", sep = ""))
	cat("#!/bin/bash -l")
	cat("\n")
	cat(paste("#SBATCH -J", job))
	cat("\n")
	cat(paste("#SBATCH -o ", job, ".output", sep = ""))
	cat("\n")
	cat("#SBATCH -e ", job, ".error", sep = "")
	cat("\n")
	cat("#SBATCH --mail-user valentina.peona90@gmail.com")
	cat("\n")
	cat("#SBATCH --mail-type=ALL")
	cat("\n")
	cat("#SBATCH -t 00:15:00")
	cat("\n")
	cat("#SBATCH -A snic2019-8-371")
	cat("\n")
	cat("#SBATCH -p core")
	cat("\n")
	cat("#SBATCH -n 2")
	cat("\n")
	cat("module load bioinfo-tools blast")
	cat("\n")
	cat(paste("cp -t $SNIC_TMP", target, query))
	cat("\n")
	cat("cd $SNIC_TMP")
	cat("\n")
	target = basename(target)
	cat(paste("makeblastdb -in", target, "-dbtype nucl -parse_seqids -out", target))
	cat("\n")
	query = basename(query)
	cat(paste("blastn -db ", target, " -query ", query, " -task blastn -perc_identity ", id, " -outfmt '6 qseqid qlen qstart qend sseqid slen sstart send sstrand length pident evalue' -out ", folder, "/", job, ".out -num_threads 8", sep = "" ))
	cat("\n")
	sink()
}
