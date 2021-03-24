#!/bin/bash
# Desenvolupa un script que ha de baixar un fitxer de nom usuaris.ods d'aquest enllaç: http://www.collados.org/asix2/m06/uf2/pr2/usuaris.ods. 
# A continuació el programa ha de convertir el fitxer .ods en un fitxer de texte pla .csv amb l'ajut que trobaràs a (1) o també a (3). 
# Amb la llista d'usuaris en format .csv i l'ajut que trobaràs a (2), has de crear un usuari del sistema per cada usuari de la llista 
# amb un nom d'usuari igual al de la llista i que sigui membre per defecte del grup users.  Comença  el número UID a partir del 3001 per seguretat. 
# La resta de dades és al teu criteri personal. Si l'arxiu de guió finalitza correctament i amb èxit,  assignarà el valor 0 com a codi de retorn. El nom del script serà mltusr.sh.
function ROOT(){
    if [ "$EUID" -ne 0 ]
        then echo "Aquest script ha de ser executat com a root"
        exit
    fi
}

function DOWNLOAD_ODS(){
    mkdir tmp > /dev/null 2>&1 
    wget -P tmp/ http://www.collados.org/asix2/m06/uf2/pr2/usuaris.ods > /dev/null 2>&1 && echo "[OK] Descarregar llista d'usuaris " || echo "[ERROR] Descarregar llista d'usuaris "
}

function CONVERT_ODS_TO_CSV(){
    libreoffice --convert-to csv --outdir tmp/ tmp/usuaris.ods > /dev/null 2>&1 && echo "[OK] Convertir ODS a CSV" || echo "[ERROR] Convertir ODS a CSV"
}

function IMPORT_USERS(){
    USRARRAY=($(awk -F "\"*,\"*" '{print $2}' tmp/usuaris.csv))
    UIDUSR=3001
    for USER in "${USRARRAY[@]}"
    do
        useradd  $USER  -u  $UIDUSR  -g  users  -d  /home/$USER  -m  -s  /bin/bash  -k  /etc/skel -p  $(mkpasswd  FjeClot2020) > /dev/null 2>&1 && echo "[OK] $USER Creat" || echo "[ERROR] $USER No Creat"
        let UIDUSR=UIDUSR+1
    done
}

function CLEAN_FINAL(){
    rm -rf tmp/
    echo "[OK] Arxius descarregats eliminats"
}

##########
# MAIN
##########

ROOT
DOWNLOAD_ODS
CONVERT_ODS_TO_CSV
IMPORT_USERS
CLEAN_FINAL