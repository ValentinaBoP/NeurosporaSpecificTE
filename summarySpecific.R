#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

wd = args[1]

setwd(wd)

list_dirs = read.table("list_dirs_fragments", stringsAsFactors = F, header = F)[,1]
list_species = unique(unlist(strsplit(x = list_dirs, split = "_")))

summary = data.frame(Genome = list_species)

for(i in 1:length(list_dirs)){

 setwd(list_dirs[i])
 cat(list_dirs[i], "\n")
 if(length(list.files(pattern = "final.filter")) == 0){
  setwd("../")
  next
} else {
 cmd = "wc -l *.final.filter"
 total = system(cmd, intern = TRUE)
 if(length(total) > 1){
 boo = grepl(pattern = "total", x = total)
 total = total[boo]
 total = trimws(x = total, which = "left")
 total = as.integer(unlist(strsplit(x = total, split = " "))[1])
 #total = as.integer(sub(x = sub(pattern = " total", x = total, replacement = ""), pattern = " ", replacement = ""))
} else {
 total = trimws(x = total, which = "left")
 total = as.integer(unlist(strsplit(x = total, split = " "))[1])
}
 genome1 = sub(pattern = "_.*", replacement = "", x = list_dirs[i])
 genome2 = sub(pattern = "*.*_", replacement = "", x = list_dirs[i])
 row = which(grepl(pattern = genome1, x = summary$Genome))
 
 summary[row, genome2] = total
 
 setwd("../")
}
}

#o = match(table = names(summary), x = summary$Genome)
#test = names(summary)[2:8]
#o = c(1,o)
#summary = summary[,o]

wd = basename(wd)

write.table(x = summary, file = paste(wd, "_summary_specific_insertions.tbl", sep = ""), quote = F, sep = '\t', row.names = F, col.names = T)

write.table(x = summary, file = paste("/proj/sllstore2017101/nobackup/b2011231_nobackup/Valentina/SpecificTE/Results/", wd, "_summary_specific_insertions.tbl", sep = ""), quote = F, sep = '\t', row.names = F, col.names = T)
