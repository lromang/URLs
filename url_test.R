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
urls <- apply(urls, 2, function(t)t <- str_replace_all(t, "\n", ""))
urls <- apply(urls, 2, function(t)t <- str_replace_all(t, "\t", ""))
urls <- apply(urls, 2, function(t)t <- str_replace_all(t, "\r\n", ""))

## Escribir base
write.table(urls, "urls.psv", sep = "|",  row.names = FALSE)


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
urls_code$slug <- str_trim(urls_code$slug)

## Función para clasificar una liga
change_lable <- function(lable){
    class <- "no disponible"
    if(str_detect(lable, "20[0-3]") |
       str_detect(lable, "406")     |
       str_detect(lable, "00.")     |
       str_detect(lable, "30.")     |
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

###################################
### Enviar resultados
###################################

send_ticket <- function(dep, urls, recs, dates, stat, admi, idad){
    op_curl <- paste0(
        "curl https://mxabierto.zendesk.com/api/v2/tickets.json   -d ", "'", '{"ticket": {"subject": "Comentarios que sugieren atención a un Recurso de Datos", "comment": { "body": "Estimado ', admi, ", \n\n En un intento por mejorar el servicio de Datos Abiertos, perfeccionar los Recursos de Datos que las Dependencias de la Administración Pública publican y asegurar su accesibilidad y permanencia, esta Dirección General ha realizado un ejercicio de prueba -con la intención de hacerlo permanente- para comprobar el funcionamiento de la descarga de sus recursos de datos. Durante dicha prueba, detectamos posibles problemas con los siguientes recursos de datos bajo su responsabilidad:

")

   f_urls <- paste(
       paste(paste0("Recurso: ", recs), paste0("URL: ", urls), paste0("Fecha de prueba: ", dates), sep = "\n" ),
       collapse = "\n----------------------\n "
   )

   conc <- "\n\n Los errores pueden ser los siguientes:

1.- El servidor no está disponible.
2.- El recurso requiere derechos de acceso.
3.- El servidor toma demasiado tiempo en responder a una solicitud por el recurso.

 Amablemente sugerimos atender dichas ligas y revisar todos los conjuntos de datos restantes que su dependencia publica en el sitio. Sin más por el momento, me mantengo a su disposición para resolver cualquier duda sobre el proceso de cumplimiento de la Política de Datos Abiertos en el correo escuadron@datos.gob.mx o vía telefónica al 50935300 ext: 7054.

Saludos cordiales.

"

    cl_curl <- paste0('"}, "status": "new", "type": "task", "priority": "normal", "tags": ["ligas_rotas"], "requester_id": ', '"', idad,'"}', "}'",' -H "Content-Type: application/json" -v -u luis.roangarci@gmail.com:Ikidefenix131090 -X POST')

    all_text <- paste(op_curl, f_urls, conc, cl_curl, sep = "\n")
    writeLines(all_text, "test.txt")
    system(all_text)
}

#######
## Prueba
#######
data_test <- head(all_data[all_data$status != "disponible",])
urls      <- data_test$url
recs      <- data_test$rec
dates     <- data_test$date
admi      <- "Carlos Castro Correa"
ida       <- "1163470257"

send_ticket(dep, urls, recs, dates, stat, admi, idad)
