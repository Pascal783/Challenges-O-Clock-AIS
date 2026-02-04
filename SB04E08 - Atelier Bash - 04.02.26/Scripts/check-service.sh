#!/bin/bash

# 1. DÉFINITION DES COULEURS

# On utilise des variables pour rendre le code plus lisible
VERT='\033[0;32m'
ROUGE='\033[0;31m'
JAUNE='\033[1;33m'
NC='\033[0m' # No Color 

# 2. VÉRIFICATION DU FICHIER DE CONFIG
FICHIER="services.conf"

# NETTOYAGE DU FICHIER (Format Windows vers Linux)
sed -i 's/\r//' "$FICHIER"

if [ ! -f "$FICHIER" ]; then
    echo -e "${ROUGE}Erreur : Le fichier $FICHIER est introuvable !${NC}"
    exit 1
fi

# --- 3. INITIALISATION DES COMPTEURS ---
ACTIFS=0
INACTIFS=0

echo ""
echo -e "${JAUNE}--- RAPPORT D'ÉTAT DES SERVICES ---${NC}\n"
echo ""

# --- 4. LECTURE DU FICHIER ET VÉRIFICATION ---
# Boucle sur chaque ligne du fichier
while read -r SERVICE; do
    # On ignore les lignes vides
    if [ -z "$SERVICE" ]; then
        continue
    fi

    if systemctl is-active --quiet "$SERVICE"; then
        echo -e "Service [ $SERVICE ] : ${VERT}ACTIF${NC}"
        ACTIFS=$((ACTIFS + 1))
    else
        echo -e "Service [ $SERVICE ] : ${ROUGE}INACTIF${NC}"
        INACTIFS=$((INACTIFS + 1))
    fi

done < "$FICHIER"

# --- 5. RÉSULTAT FINAL ---
echo ""
echo -e "------------------------------------"
echo ""
echo -e "Résumé :"
echo -e "${VERT}Services actifs   : $ACTIFS${NC}"
echo -e "${ROUGE}Services inactifs : $INACTIFS${NC}"
echo ""
echo -e "------------------------------------"