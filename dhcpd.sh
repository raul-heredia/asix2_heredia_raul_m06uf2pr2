#!/bin/bash

# Fa un còpia de seguretat de l'arxiu actual de configuració del servidor DHCP afegint l'any, mes, dia,hora i minut al seu nom (Per exemple dhpcd.conf.201702091950)
# Demana a l'administrador el nom de domini
# Demana a l'administrador per teclat l'adreça  IP del servidor DNS (només 1 servidor)
# Demana a l'administrador per teclat l'adreça IP del router per defecte
# Demana a l'administrador per teclat el valor del temps de leasing per defecte
# Demana a l'administrador per teclat el valor del temps de leasing màxim
# Demana a l'administrador per teclat l'adreça IP de la subxarxa dins de la qual s'assignaran adreces IP
# Demana a l'administrador per teclat la màscara de la subxarxa
# Demana a l'administrador per teclat la primera adreça IP del marge d'adreces IP assignades pel servidor
# Demana a l'administrador per teclat l'última adreça IP del marge d'adreces IP assignades pel servidor
# Fa un backup de l'arxiu de configuració antic
# Crea un nou arxiu de configuracio del servidor DHCP, tenint en compte que el servidor serà autoritatiu, que el paràmetre ddns-update-style val none.
# reinicia el servidor DHCP.

##############################################
#                 VARIABLES                  #
##############################################
TIMESTAMP=$(date +"%Y%m%d%H%M")
DHCPDIR=/etc/dhcp

function ROOT(){
    if [ "$EUID" -ne 0 ]
        then echo "Aquest script ha de ser executat com a root"
        exit
    fi
}

function COPY(){
    cp $DHCPDIR/dhcpd.conf $DHCPDIR/dhcpd.conf.$TIMESTAMP > /dev/null 2>&1 && echo "Copia de seguretat de dhcpd.conf [OK]" || echo "Copia de seguretat de dhcpd.conf [ERROR]"
    echo -n "Prem enter per continuar... "
    read pause
}
function USERINPUT(){
    clear
    echo -n "Introdueix el nom del domini: "
    read NOMDOMINI
    echo -n "Direccio IP del Servidor DNS: "
    read DNSSERVER
    echo -n "Introdueix la Gateway per defecte: "
    read GATEWAY
    echo -n "Introdueix la direccio broadcast: "
    read BROADCAST
    echo -n "Introdueix el valor del temps de leasing per defecte: "
    read DEFLEASING
    echo -n "Introdueix el valor del temps de leasing màxim: "
    read MAXLEASING
    echo -n "Introdueix la IP de la subxarxa: "
    read SUBNETIP
    echo -n "Introdueix la màscara de la subxarxa: "
    read SUBNETMASK
    echo -n "Primera IP del marge de IP: "
    read FIRSTIP
    echo -n "Última IP del marge de IP: "
    read LASTIP
}
function CHECK(){
    clear
    echo "Revisa la informació, gracies."
    echo "El nom del domini introduit es: $NOMDOMINI"
    echo "La direcció IP del servidor DNS es: $DNSSERVER"
    echo "La Gateway per defecte introduida es: $GATEWAY"
    echo "La direcció bradcast introduida es: $BROADCAST"
    echo "El valor del temps de leasing per defecte introduit es: $DEFLEASING"
    echo "El valor del temps de leasing màxim introduit es: $MAXLEASING"
    echo "La IP de subxarxa introduida es: $SUBNETIP"
    echo "La màscara de subxarxa introduida es: $SUBNETMASK"
    echo "La primera direccio IP del marge es: $FIRSTIP"
    echo "La darrera direccio IP del marge es: $LASTIP"
    echo -n "Vols continuar? [Y/n]: "
    read OPTION

    if [[ $OPTION == "N" || $OPTION == "n" ]]; then
        exit;
    else
        clear
    fi

}

function CREATE_FILE(){
    echo -n "#Generat per dhcpd.sh
ddns-update-style none;

subnet $SUBNETIP netmask $SUBNETMASK{
    range $FIRSTIP $LASTIP;
    option domain-name-servers $DNSSERVER;
    option domain-name \"$NOMDOMINI\";
    option subnet-mask $SUBNETMASK;
    option routers $GATEWAY;
    option broadcast-address $BROADCAST;
    default-lease-time $DEFLEASING;
    max-lease-time $MAXLEASING;
}
" > $DHCPDIR/dhcpd.conf && echo "Fitxer Generat [OK]" || echo "Fitxer Generat [ERROR]"  
}

function RESTART_DHCP(){
    systemctl restart isc-dhcp-server.service
    if [[ "$?" == 0 ]];then
    echo "Reinici DHCP [OK]"
    else
    echo "Reinici DHCP [ERROR]"
    fi
}
    
##########
# MAIN
##########
    ROOT
    COPY
    USERINPUT
    CHECK
    CREATE_FILE
    RESTART_DHCP