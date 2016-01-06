#! /usr/bin/Rscript

###################################
###### Librerias utilizadas #######
###################################
library(RCurl)
library(stringr)
library(plyr)
library(R.utils)

###################################
### Obtencion de URLs
###################################
data <- read.csv("https://raw.githubusercontent.com/lromang/MiningDatosGob/master/Datasets/MAT.csv",
                stringsAsFactors = FALSE)
urls <- data[,c(1,2,6,9)]

## Escribir base
write.table(urls, "urls.psv", sep = "|" , row.names = FALSE)


######################################################################
######################################################################
###################### Ejecutar url_test.sh ##########################
######################################################################
######################################################################

###################################
### Clasificación de ligas
###################################
urls_code <- read.csv("urlstatus.csv",
                     stringsAsFactors = FALSE,
                     header           = FALSE)

names(urls_code) <- c("dep", "slug", "rec", "url", "code", "exec_time", "date")

## Función para clasificar una liga
change_lable <- function(lable){
    class <- "no disponible"
    if(str_detect(lable, "20[0-3]") |
       str_detect(lable, "00.")     |
       str_detect(lable, "300")     |
       str_detect(lable, "30[2-7]") |
       str_detect(lable, "50.")
       ){
        class <- "disponible"
    }
    class
}

## Función para clasificar una columna de ligas.
change_lable_mult <- function(col){
    laply(col, function(t) t <- change_lable(t))
}

## Clasificacion de ligas.
urls_code$status <- change_lable_mult(urls_code$code)

###################################
### Incluir usuarios
###################################
users    <- read.csv("users.csv", stringsAsFactors = FALSE)

all_data <- merge(urls_code, users, by = "slug")

###################################
### Escribir resultados
###################################
write.csv(all_data, "all_data_urls.csv", row.names = FALSE)
