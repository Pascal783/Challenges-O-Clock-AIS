#!/bin/bash

# 1. Liste des serveurs à tester
# On les met dans une liste séparée par des espaces
SERVEURS="google.com github.com cloudflare.com microsoft.com facebook.com"

# Nom du fichier pour enregistrer les résultats
FICHIER_RESULTAT="resultat_ping.txt"

# Compteur pour le résumé final
SUCCES=0
TOTAL=0

echo ""
echo "--- TEST DE CONNECTIVITÉ RÉSEAU ---"
echo ""
echo "Analyse en cours, veuillez patienter..."
echo ""

# On vide le fichier de résultat s'il existait déjà
echo "Rapport réseau du $(date)" > $FICHIER_RESULTAT
echo "------------------------------" >> $FICHIER_RESULTAT

# 2. Boucle pour tester chaque serveur
for SERVEUR in $SERVEURS; do
    TOTAL=$((TOTAL + 1))
    
    # On envoie 2 pings (-c 2) et on attend maximum 2 secondes (-W 2)
    # On cache le texte inutile avec > /dev/null
    if ping -c 2 -W 2 $SERVEUR > /dev/null; then
        echo "[ OK ] $SERVEUR est accessible"
        echo "$SERVEUR : ACCESSIBLE" >> $FICHIER_RESULTAT
        SUCCES=$((SUCCES + 1))
    else
        echo "[ERREUR] $SERVEUR est INACCESSIBLE !"
        echo "$SERVEUR : ÉCHEC" >> $FICHIER_RESULTAT
    fi
done

# 3. Résumé final
echo ""
echo "--- RÉSUMÉ ---"
echo ""
echo "Score : $SUCCES / $TOTAL serveurs répondent."
echo ""
# On écrit aussi le score dans le fichier
echo "------------------------------" >> $FICHIER_RESULTAT
echo "Score final : $SUCCES / $TOTAL" >> $FICHIER_RESULTAT

echo "Le rapport complet est disponible dans : $FICHIER_RESULTAT"
echo ""