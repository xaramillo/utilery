#!/usr/bin/env Rscript

stfu = suppressPackageStartupMessages

stfu(library(data.table))
stfu(library(tidyverse))

arguments = commandArgs(T)
file = arguments[1]

gff = fread(file) %>% as.data.frame()
colnames(gff) = c("seqname","source","feature","start","end","score","strand","frame","attribute")

attributes = gff$attribute %>% str_split(pattern = ";", simplify = T)

transcript_id = attributes[,2] %>% str_split(pattern = "\\|", simplify = T)
transcript_id = transcript_id %>% str_replace(pattern = "Parent=gene-", replacement = "")


gff$transcript_names = transcript_id
gff$start = gff$start - 1


#print(gff[,c("seqname","start","end","transcript_names")], row.names=F)

gff$fasta_names = paste(gff$seqname,":",gff$start,"-",gff$end,sep="")

#print(gff[,c("fasta_names","transcript_names")], row.names=F)

cat(format_csv(gff[,c("fasta_names","transcript_names")]))

