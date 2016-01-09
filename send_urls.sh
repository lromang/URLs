#!/bin/bash

for i in $(seq `tail -n +2  all_data_urls.csv | wc -l`)
do
    # Get row
    row=$(tail -n +2 all_data_urls.csv |awk 'FNR == "'"$i"'" {print}' | sed 's/"//g')

    # Get data
    dep=$(echo $row | cut -d '|' -f2)
    url=$(echo $row | cut -d '|' -f4)
    rec=$(echo $row | cut -d '|' -f3)
    date=$(echo $row | cut -d '|' -f7)
    stat=$(echo $row | cut -d '|' -f8)
    admi=$(echo $row | cut -d '|' -f9)
    idad=$(echo $row | cut -d '|' -f11)

    # Check if not disp.
    if [ $stat -ne "disponible" ]
    then
        curl https://mxabierto.zendesk.com/api/v2/tickets.json   -d '{"ticket": {"subject": "Comentarios que sugieren atención a un Recurso de Datos", "comment": { "body": "Estimado $admi,

En un intento por mejorar el servicio de Datos Abiertos, perfeccionar los Recursos de Datos que las Dependencias de la Administración Pública publican y asegurar su accesibilidad y permanencia, esta Dirección General ha realizado un ejercicio de prueba -con la intención de hacerlo permanente- para comprobar el funcionamiento de la descarga de sus recursos de datos. Durante dicha prueba, detectamos posibles problemas con los siguientes recursos de datos bajo su responsabilidad:

fecha de la prueba: $date
recurso: $rec
url: $url

Amablemente sugerimos atender dichas ligas y revisar todos los conjuntos de datos restantes que su dependencia publica en el sitio. Sin más por el momento, me mantengo a su disposición para resolver cualquier duda sobre el proceso de cumplimiento de la Política de Datos Abiertos en el correo escuadron@datos.gob.mx o vía telefónica al 50935300 ext: 7054.

Saludos cordiales

" }, "status": "new", "type": "task", "priority": "normal", "tags": ["ligas_rotas"], "requester_id": "$idad"}}' -H "Content-Type: application/json" -v -u luis.roangarci@gmail.com:Ikidefenix131090 -X POST
    fi
done
