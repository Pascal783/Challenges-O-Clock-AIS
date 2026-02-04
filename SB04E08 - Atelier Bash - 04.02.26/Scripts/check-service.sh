#!/bin/bash

# 1. DÉFINITION DES COULEURS

# On utilise des variables pour rendre le code plus lisible
VERT='\033[0;32m'
ROUGE='\033[0;31m'
JAUNE='\033[1;33m'
NC='\033[0m' # No Color 

# --- CONFIGURATION ---
RESTART_AUTO="oui"     
FICHIER_JSON="services.json"
echo "[" > "$FICHIER_JSON" 

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
echo -e "${JAUNE}--- RAPPORT D'ÉTAT DES SERVICES ---${NC}"
echo ""

# --- 4. LECTURE DU FICHIER ET VÉRIFICATION ---
# Boucle sur chaque ligne du fichier
while read -r SERVICE; do
    # On ignore les lignes vides
    if [ -z "$SERVICE" ]; then
        continue
    fi

    # Vérification Enabled
    ENABLED="non"
    if systemctl is-enabled --quiet "$SERVICE" 2>/dev/null; then ENABLED="oui"; fi

    if systemctl is-active --quiet "$SERVICE"; then
        echo -e "Service [ $SERVICE ] : ${VERT}ACTIF${NC} (Auto-boot: $ENABLED)"
        ACTIFS=$((ACTIFS + 1))
        STATUT="ACTIF"
    else
        # Ici, on considère que TOUS les services du fichier sont importants
        echo -e "Service [ $SERVICE ] : ${ROUGE}INACTIF${NC} (Auto-boot: $ENABLED)"
        echo -e "${ROUGE}  >> ALERTE : Le service $SERVICE est arrêté !${NC}"
        
        INACTIFS=$((INACTIFS + 1))
        STATUT="INACTIF"

        # Tentative de redémarrage
        if [ "$RESTART_AUTO" == "oui" ]; then
            echo -e "${JAUNE}  >> Tentative de redémarrage de $SERVICE...${NC}"
            systemctl start "$SERVICE" 2>/dev/null
        fi
    fi

    echo "  { \"service\": \"$SERVICE\", \"status\": \"$STATUT\", \"enabled\": \"$ENABLED\" }," >> "$FICHIER_JSON"

done < "$FICHIER"

# --- 5. RÉSULTAT FINAL ---
echo ""
echo "  { \"date\": \"$(date)\" }" >> "$FICHIER_JSON"
echo "]" >> "$FICHIER_JSON"
echo ""
echo -e "------------------------------------"
echo ""
echo -e "Résumé :"
echo -e "${VERT}Services actifs   : $ACTIFS${NC}"
echo -e "${ROUGE}Services inactifs : $INACTIFS${NC}"
echo ""
echo -e "Rapport détaillé créé : $FICHIER_JSON"
echo ""
echo -e "------------------------------------"