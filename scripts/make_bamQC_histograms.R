#!/usr/bin/env Rscript

# define custom plotting function 
make_histogram <- function(data, column, stats = FALSE, title = "per site depth", scale = "full"){
  x <- suppressWarnings(as.numeric(data[, column]))

  if(scale == "full"){
    hist(x, main = title, breaks = 1e2)
  }else if(scale == "zoom"){
    hist(x, main = title, breaks = 1e6, xlim=c(0, median(x)*5))
  }
  
  if(stats==TRUE){
    abline(v = median(x), col = "black", lwd = 1)
    mtext(median(x), at = median(x))
    abline(v = (median(x)*1.5), col = "red", lwd = 1)
    abline(v = (median(x)*0.5), col = "red", lwd = 1)
    abline(v = (median(x)*0.75), col = "blue", lwd = 1)
    abline(v = (median(x)*1.25), col = "blue", lwd = 1)
    abline(v = (median(x)*2), col = "green", lwd = 1)
    legend("topright", legend = c("+/- 0.5", "+/- 0.25", "x2", 
                                  (median(x)*1.5), 
                                  (median(x)*0.5), 
                                  (median(x)*0.75), 
                                  (median(x)*1.25), 
                                  (median(x)*2)), col = c("red", "blue", "green", "red", "red", "blue", "blue", "green"), lty = 1, lwd = 2)
  }
}

args <- commandArgs(trailingOnly=TRUE)

# capture arguments
filePath <- args[1] 
outFile <- args[2]

# read in bamstats files
files <- list.files(path = filePath, pattern = ".bamstats", full.names = TRUE)
data <- do.call(rbind, lapply(files, read.csv, sep = "\t"))

chrom_list <- unique(data$chr)

### START PLOTTING 
pdf(file = outFile, height = 6, width = 6)

# all data 
# depth
make_histogram(data, title = "all scaffolds", column = "depth", stats = TRUE) # full x lim 
make_histogram(data, title = "all scaffolds, zoom", column = "depth", stats = TRUE, scale = "zoom") # full x lim 
# other categories 
for(i in 3:ncol(data)){
  make_histogram(data, title = colnames(data)[i], column = i) 
}

# fraction_mapq0

# one histogram per chromosome 

for(c in 1:length(chrom_list)){

  make_histogram(data[which(data$chr == chrom_list[c]),], title = "all scaffolds", column = "depth", stats = TRUE) # full x lim 
  make_histogram(data[which(data$chr == chrom_list[c]),], title = "all scaffolds, zoom", column = "depth", stats = TRUE, scale = "zoom") # full x lim 
  # other categories 
  for(i in 3:ncol(data)){
    make_histogram(data[which(data$chr == chrom_list[c]),], title = paste0(chrom_list[c], ": ", colnames(data)[i]), column = i) 
  }
  
  
}

dev.off()
### END PLOTTING