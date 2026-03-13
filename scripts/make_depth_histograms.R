#!/usr/bin/env Rscript

# define custom plotting function 
make_histogram <- function(data, title = "per site depth"){
  hist(data$depth, main = title, breaks = 1e2)
  abline(v = median(data$depth), col = "black", lwd = 1)
  mtext(median(data$depth), at = median(data$depth))
  abline(v = (median(data$depth)*1.5), col = "red", lwd = 1)
  abline(v = (median(data$depth)*0.5), col = "red", lwd = 1)
  abline(v = (median(data$depth)*0.75), col = "blue", lwd = 1)
  abline(v = (median(data$depth)*1.25), col = "blue", lwd = 1)
  abline(v = (median(data$depth)*2), col = "green", lwd = 1)
  legend("topright", c("+/- 0.5", "+/- 0.25", "x2"), col = c("red", "blue", "green"), lty = 1, lwd = 2)
  legend("bottomright", legend = c((median(data$depth)*1.5), 
                                   (median(data$depth)*0.5), 
                                   (median(data$depth)*0.75), 
                                   (median(data$depth)*1.25), 
                                   (median(data$depth)*2)), col = c("red", "red", "blue", "blue", "green"), lty = 1, lwd = 2)
  
}

args <- commandArgs(trailingOnly=TRUE)

# capture arguments
filePath <- args[1] 
outFile <- args[2]

# read in depth files
files <- list.files(path = filePath, pattern = "depth_summary.txt", full.names = TRUE)

data <- do.call(rbind, lapply(files, read.table, col.names = c("chr", "pos", "depth")))

# get list of scaffolds/chromosomes
chrom_list <- unique(data$chr)

pdf(file = outFile, height = 6, width = 6)

# joint histogram
make_histogram(data, title = "all scaffolds")

# one histogram per chromosome 

for(c in 1:length(chrom_list)){
  make_histogram(data[which(data$chr == chrom_list[c]),], title = chrom_list[c])
}

dev.off()
