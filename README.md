# URLs

This repo contains several scripts that programmatically verify the state of all the URLs available at [datos gob](datos.gob.mx).

## Execution

In order to execute the program, the following steps must be taken:

1. Give execution permissions to all the scripts. Namely: class_and_send_urls.R,  get_urls.R and url_test.sh.
 
this is accomplished by typing `chmod u+x name_of_script` in the command line.

2. Execute get_urls.R by typing `./get_urls.R` in the command line. This will create the file urls.psv.

3. Execute url_test.sh by typing `./url_test.sh k` in the command line, where k is the maximum time allowed for each test. This will create the file urlstatus.csv.

4. Finally, execute class_and_send_urls.R by typing `./class_and_send_urls.R`.

