#!/bin/bash

# 1. Variables
NOM_SERVEUR=$(hostname)
DATE=$(date "+%d/%m/%Y %H:%M:%S")
UPTIME=$(uptime -p)

# 2. Calculs techniques (CPU et Mémoire)
# CPU : Récupération de la charge moyenne transformé en %
CHARGE_CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

# Mémoire : 'free -g' pour avoir les Go
MEM_TOTALE=$(free -g | awk '/Mem:/ {print $2}')
MEM_UTILISEE=$(free -g | awk '/Mem:/ {print $3}')
# Calcul du pourcentage (Utilisée / Totale * 100)
MEM_POURCENT=$(free | awk '/Mem:/ {printf("%.2f"), $3/$2*100}')

# 3. Processus
NB_PROCESSUS=$(ps aux | wc -l)

# 4. Rapport
echo ""
echo "==========================================="
echo "   Informations Système - $NOM_SERVEUR"
echo "==========================================="
echo ""
echo "Date et Heure : $DATE"
echo "Temps de service (Uptime) : $UPTIME"
echo "Nombre de processus : $NB_PROCESSUS"
echo ""
echo "-------------------------------------------"
echo ""
echo "Utilisation CPU    : $CHARGE_CPU%"
echo "Utilisation Mémoire: ${MEM_UTILISEE}Go / ${MEM_TOTALE}Go ($MEM_POURCENT%)"
echo ""
echo "-------------------------------------------"
echo ""
echo "Utilisation des partitions (Disques) :"
# On affiche les colonnes Système de fichiers, Taille, et Utilisation %
df -h --output=source,size,pcent | grep '^/'
echo ""
echo "==========================================="