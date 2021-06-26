#!/usr/bin/env Rscript
stfu = suppressPackageStartupMessages


stfu(library(data.table))
stfu(library(tidyverse))


arguments = commandArgs(T)

reference_file = arguments[1]
change_file = paste( "grep -v '^#'" , arguments[2], sep=" ")

reference = fread(reference_file) %>% as.data.frame()
change = fread(cmd=change_file) %>% as.data.frame()

column_id = colnames(change)[1]
print(column_id)
z = merge(x= reference, y= change ,by.x="fasta_names" ,by.y= column_id)

cat(format_tsv(z, col_names=F))

