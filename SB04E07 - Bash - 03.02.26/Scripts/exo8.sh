#!/bin/bash

# Codes pour les couleurs
ROUGE='\033[0;31m'
VERT='\033[0;32m'
NEUTRE='\033[0m'

echo ""
echo "=== ANALYSE DE L'ESPACE DISQUE ==="
echo ""

# 1. Analyse des partitions
echo ""
echo "--- État des partitions ---"
echo ""
# lecture du résultat de df ligne par ligne (sauf la première)
df -h | grep '^/' | while read LIGNE; do
    # Récupération du pourcentage d'utilisation (ex: 85%)
    USAGE=$(echo $LIGNE | awk '{print $5}' | sed 's/%//')
    
    if [ "$USAGE" -gt 80 ]; then
        echo -e "${ROUGE}ATTENTION : $LIGNE${NEUTRE}"
    else
        echo -e "${VERT}OK : $LIGNE${NEUTRE}"
    fi
done

echo ""

# 2. Les 10 plus gros dossiers dans /home
echo "--- Liste des 10 plus gros dossiers dans /home ---"
echo ""
echo "Patientez pendant le calcul..."
echo ""
# du -h : taille lisible, -d 1 : profondeur de 1 dossier, sort -h : trier par taille
RESULTAT_TOP10=$(sudo du -h -d 1 /home 2>/dev/null | sort -hr | head -n 10)
echo "$RESULTAT_TOP10"

echo ""

# 3. Option d'export
echo -n "Voulez-vous exporter ce rapport dans 'rapport_disque.txt' ? (oui/non) : "
read REPONSE

if [ "$REPONSE" == "oui" ]; then
    echo "--- RAPPORT DU $(date) ---" > rapport_disque.txt
    echo "UTILISATION PARTITIONS :" >> rapport_disque.txt
    df -h >> rapport_disque.txt
    echo "" >> rapport_disque.txt
    echo "Liste des 10 plus gros dossiers /HOME :" >> rapport_disque.txt
    echo "$RESULTAT_TOP10" >> rapport_disque.txt
    echo "Le fichier rapport_disque.txt a été créé."
else
    echo "Fin de l'analyse."
fi