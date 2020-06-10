library(data.table)
library(dplyr)

files = list.files(pattern = "window")

for (file in files){

	window = fread(file)
	
	# filter for the flanks of the same element that align close to one another
	window$ID = sub(pattern = "_flank3", replacement = "_flank5", x = window$V13)
	boo = window$V4 == window$ID
	filter = window[boo,]
	
	# filter for alignment length
	boo = filter$V5 >= 100
	filter = filter[boo,]
	
	# filter for position of the alignment: close to the interface
	boo = filter$V9 >= 400 & filter$V18 >= 400
	filter = filter[boo,]
	
	# save intermediate file with the coordinates of the putative empty sites
	filename = sub(pattern = ".window", replacement = "_putativeEmpty", x = file)
	write.table(x = filter, file = filename, sep = "\t", quote = F, col.names = F, row.names = F)
	
	# make BED format of the putative empty sites
	bed = data.frame(chr = character(), start = integer(), end = integer(), name = character(), score = integer(), strand = character())
	if(nrow(filter) > 0){
	
		for(j in 1:nrow(filter)){
		
		chr = filter[j, 1]
		start = min(filter[j, c(2,3,11,12)])
		end = max(filter[j, c(2,3,11,12)])
		name = sub(pattern = "_flank5", replacement = "", x = filter[j, 4])
		score = filter[j, 5]
		strand = filter[j, 6]
		
		newLine = data.frame(chr = chr, start = start, end = end, name = name, score = score, strand = strand)
		
		bed = rbind(bed, newLine)
	
	}
	
	# save bed file for putative empty sites
	filename = sub(pattern = ".window", replacement = "_putativeEmpty.bed", x = file)
	write.table(x = bed, file = filename, sep = "\t", quote = F, col.names = F, row.names = F)
	
	
	} else {
	
	print("empty file")
	
	}

}
