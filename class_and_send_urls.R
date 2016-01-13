#! /usr/bin/Rscript

###################################
###### Librerias utilizadas #######
###################################
suppressPackageStartupMessages(library(RCurl))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(plyr))
suppressPackageStartupMessages(library(R.utils))
suppressPackageStartupMessages(library(data.table))


###################################
### Clasificación de ligas
###################################
urls_code <- fread("urlstatus.csv",
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

send_ticket <- function(dep, urls, recs, dates, admi, idad, subid, email){
    op_curl <- paste0(
        "curl https://mxabierto.zendesk.com/api/v2/tickets.json -d ", "'", '{"ticket": {"subject": "Comentarios que sugieren atención a un Recurso de Datos", "comment": { "body": "Estimado ', admi,",\\n\\nEn un intento por mejorar el servicio de Datos Abiertos, perfeccionar los Recursos de Datos que las Dependencias de la Administración Pública publican y asegurar su accesibilidad y permanencia, esta Dirección General ha realizado un ejercicio de prueba -con la intención de hacerlo permanente- para comprobar el funcionamiento de la descarga de sus recursos de datos. Durante dicha prueba, detectamos posibles problemas con los siguientes recursos de datos bajo su responsabilidad:\\n\\n")

    f_urls <- paste(
       paste(paste0("Recurso: ", recs), paste0("URL: ", urls), paste0("Fecha de prueba: ", dates), sep = "\\n\\n" ),
       collapse = "\\n\\n----------------------\\n\\n"
   )

    conc <- "\\n\\nLos errores pueden ser los siguientes:\\n\\n1.- El servidor no está disponible.\\n\\n2.- El recurso requiere derechos de acceso.\\n\\n3.- El servidor toma demasiado tiempo en responder a una solicitud por el recurso.\\n\\nAmablemente sugerimos atender dichas ligas y revisar todos los conjuntos de datos restantes que su dependencia publica en el sitio. Sin más por el momento, me mantengo a su disposición para resolver cualquier duda sobre el proceso de cumplimiento de la Política de Datos Abiertos en el correo escuadron@datos.gob.mx o vía telefónica al 50935300 ext: 7054.\\n\\nSaludos cordiales."
    cl_curl <- paste0('"}, "status": "new", "type": "task", "priority": "normal", "tags": ["ligas_rotas"], "collaborator_ids":[',subid ,'] ,"requester": {"id":', idad,',"name":','"', admi,'", "email":', '"', email,'"}}', "}'",' -H "Content-Type: application/json" -v -u luis.roangarci@gmail.com:Ikidefenix131090 -X POST')

    all_text <- paste(op_curl, f_urls, conc, cl_curl, sep = "")
    ## writeLines(all_text, "test.txt")
    if(length(urls) > 0){
        system(all_text)
    }
}

send_multi_ticket <- function(all_data_non_disp){
    deps <- unique(all_data_non_disp$slug)
    for(i in 1:length(deps)){
        send_to <- dplyr::filter(all_data_non_disp, slug == deps[i])
        urls    <- send_to$url
        recs    <- send_to$rec
        dates   <- send_to$date
        ## email   <- "carlos.castro@presidencia.gob.mx"
        ## admi    <- "Carlos Castro Correa"
        ## idad    <- "1163470257"
        ## subid   <- "1163470257"
        email   <- send_to$mail_adm[1]
        admi    <- send_to$administrador[1]
        idad    <- send_to$id_zen_adm[1]
        subid   <- send_to$id_zen_adm[1]
        send_ticket(deps[i], urls, recs, dates, admi, idad, subid, email)
    }
}
#######
## Prueba
#######
data_test <- all_data[all_data$status != "disponible",]
data_test <- data_test[data_test$slug != "pemex",]
send_multi_ticket(data_test)
