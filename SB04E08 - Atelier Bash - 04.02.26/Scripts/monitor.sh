#!/bin/bash

# Code couleur
VERT='\033[0;32m'
JAUNE='\033[1;33m'
ROUGE='\033[0;31m'
NC='\033[0m' # Pas de couleur

# Fonction pour le choix de couleur
get_color() {
    local valeur=$(printf "%.0f" "$1")
    if [ "$valeur" -lt 70 ]; then
        echo -e "$VERT"
    elif [ "$valeur" -le 85 ]; then
        echo -e "$JAUNE"
    else
        echo -e "$ROUGE"
    fi
}

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
C_CPU=$(get_color "$CHARGE_CPU")
C_MEM=$(get_color "$MEM_POURCENT")

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
echo -e "Utilisation CPU    : ${C_CPU}$CHARGE_CPU%${NC}"
echo -e "Utilisation Mémoire: ${C_MEM}${MEM_UTILISEE}Go / ${MEM_TOTALE}Go ($MEM_POURCENT%)${NC}"
echo ""
echo "-------------------------------------------"
echo ""
echo "Utilisation des partitions (Disques) :"
# On affiche les colonnes Système de fichiers, Taille, et Utilisation %
df -h --output=source,size,pcent | grep '^/'
echo ""
echo "==========================================="