#!/bin/bash

for i in $(seq `tail -n +2  urls.psv | wc -l`)
do
    # Get row
    row=$(tail -n +2 urls.psv |awk 'FNR == "'"$i"'" {print}' | sed 's/"//g')

    # Get data
    dep=$(echo $row  | cut -d '|' -f1)
    slug=$(echo $row | cut -d '|' -f2)
    rec=$(echo $row  | cut -d '|' -f3)
    url=$(echo $row  | cut -d '|' -f4)
            
    # Time prior URL verification.
    T="$(date +%s)"

    # URL verification.
    urlstatus=$(timeout $1s curl -k -o /dev/null --silent --head --write-out '%{http_code}' "$url" )

    # Verification time.
    T="$(($(date +%s)-T))"
    
    # Check if timeout.
    if [ $(echo $urlstatus | wc -m) -eq 1 ]
    then
        urlstatus="time_out"
    fi

    # Print results.
    echo  "dep: $dep | slug: $slug | rec: $rec | url: $url | status: $urlstatus | execution time: $T | date: `date`"

    # Send results to file.
    echo  "$dep,$slug,$rec,$url,$urlstatus,$T,`date`" >> urlstatus.csv
done
