#!/bin/bash
# Desenvolupa un script que ha de baixar un fitxer de nom usuaris.ods d'aquest enllaç: http://www.collados.org/asix2/m06/uf2/pr2/usuaris.ods. 
# A continuació el programa ha de convertir el fitxer .ods en un fitxer de texte pla .csv amb l'ajut que trobaràs a (1) o també a (3). 
# Amb la llista d'usuaris en format .csv i l'ajut que trobaràs a (2), has de crear un usuari del sistema per cada usuari de la llista 
# amb un nom d'usuari igual al de la llista i que sigui membre per defecte del grup users.  Comença  el número UID a partir del 3001 per seguretat. 
# La resta de dades és al teu criteri personal. Si l'arxiu de guió finalitza correctament i amb èxit,  assignarà el valor 0 com a codi de retorn. El nom del script serà mltusr.sh.


function ROOT(){ # Comprova si som root
    if [ "$EUID" -ne 0 ]
        then echo "Aquest script ha de ser executat com a root"
        exit
    fi
}

function DOWNLOAD_ODS(){ # Descarrega el ODS
    mkdir tmp > /dev/null 2>&1 
    wget -P tmp/ http://www.collados.org/asix2/m06/uf2/pr2/usuaris.ods > /dev/null 2>&1 && echo "[OK] Descarregar llista d'usuaris " || echo "[ERROR] Descarregar llista d'usuaris "
}

function CONVERT_ODS_TO_CSV(){ # Converteix el ODS al CSV
    libreoffice --convert-to csv --outdir tmp/ tmp/usuaris.ods > /dev/null 2>&1 && echo "[OK] Convertir ODS a CSV" || echo "[ERROR] Convertir ODS a CSV"
}

function IMPORT_USERS(){ #Importa els usuaris al CSV
    USRARRAY=($(awk -F "\"*,\"*" '{print $2}' tmp/usuaris.csv))
    UIDUSR=3001
}
function ADD_USERS(){ # Afegeix els usuaris del CSV
    for USER in "${USRARRAY[@]}"
    do
        useradd  $USER  -u  $UIDUSR  -g  users  -d  /home/$USER  -m  -s  /bin/bash  -k  /etc/skel -p  $(mkpasswd  FjeClot2020) > /dev/null 2>&1 && echo "[OK] Usuari $USER Creat" || echo "[ERROR] Usuari $USER No Creat"
        let UIDUSR=UIDUSR+1
    done
}
function CLEAN_FINAL(){ # Elimina els fitxers descarregats
    rm -rf tmp/
    echo "[OK] Arxius descarregats eliminats"
}

RM=0
function USERDEL(){ # Esborra els usuaris del CSV
    for USER in "${USRARRAY[@]}"
    do
        userdel  -r  $USER > /dev/null 2>&1 && echo "[OK] Usuari $USER esborrat" || echo "[ERROR] Usuari $USER No Esborrat"
    done
}

while [ "$1" != "" ]; do
    case $1 in
        -d|--delete)
        RM=1
        shift
        ;;
    esac
done



##########
# MAIN
##########

ROOT
DOWNLOAD_ODS
CONVERT_ODS_TO_CSV
IMPORT_USERS
if [[ $RM == 1 ]];then
    USERDEL
else
    ADD_USERS
fi
CLEAN_FINAL