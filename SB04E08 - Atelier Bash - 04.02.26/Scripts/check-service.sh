#!/bin/bash

# --- 1. DÉFINITION DES COULEURS ---
VERT='\033[0;32m'
ROUGE='\033[0;31m'
JAUNE='\033[1;33m'
NC='\033[0m' 

# --- CHOIX DU MODE ---
echo ""
echo "--- CONFIGURATION ---"
echo ""
read -p "Activer le mode monitoring (vérification toutes les 30s) ? (o/n) : " CHOIX_WATCH

WATCH_MODE=false
if [[ "$CHOIX_WATCH" == "o" ]]; then
    WATCH_MODE=true
fi

# Boucle infinie si WATCH_MODE est vrai, sinon ne passe qu'une fois
while true; do
    if [ "$WATCH_MODE" = true ]; then
        clear
    fi
    
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
    while read -r SERVICE; do
        if [ -z "$SERVICE" ]; then
            continue
        fi

        ENABLED="non"
        if systemctl is-enabled --quiet "$SERVICE"; then ENABLED="oui"; fi

        if systemctl is-active --quiet "$SERVICE"; then
            echo -e "Service [ $SERVICE ] : ${VERT}ACTIF${NC} (Auto-boot: $ENABLED)"
            ACTIFS=$((ACTIFS + 1))
            STATUT="ACTIF"
        else
            echo -e "Service [ $SERVICE ] : ${ROUGE}INACTIF${NC} (Auto-boot: $ENABLED)"
            echo -e "${ROUGE}  >> ALERTE : Le service $SERVICE est arrêté !${NC}"
            
            INACTIFS=$((INACTIFS + 1))
            STATUT="INACTIF"

            if [ "$RESTART_AUTO" == "oui" ]; then
                echo -e "${JAUNE}  >> Tentative de redémarrage de $SERVICE...${NC}"
                systemctl start "$SERVICE"
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

    
    if [ "$WATCH_MODE" = true ]; then
        echo -e "${JAUNE}Mode monitoring actif (30s). Ctrl+C pour quitter.${NC}"
        sleep 30
    else
        break
    fi
done