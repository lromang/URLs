#! /usr/bin/Rscript

###################################
###### Librerias utilizadas #######
###################################
suppressPackageStartupMessages(library(RCurl))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(plyr))
suppressPackageStartupMessages(library(R.utils))

###################################
### Obtencion de URLs
###################################
data <- read.csv("https://raw.githubusercontent.com/lromang/MiningDatosGob/master/Datasets/MAT.csv",
                stringsAsFactors = FALSE)
urls <- data[,c(1,2,6,9)]
urls <- apply(urls, 2, function(t)t <- str_replace_all(t, "\n", ""))
urls <- apply(urls, 2, function(t)t <- str_replace_all(t, "\t", ""))
urls <- apply(urls, 2, function(t)t <- str_replace_all(t, "\r\n", ""))

## Escribir base
write.table(urls, "urls.psv", sep = "|",  row.names = FALSE)

