#!/bin/bash

# 1. Vérifier si on a donné le nombre de jours en argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <nombre_de_jours>"
    exit 1
fi

JOURS=$1
DOSSIER_LOGS="/var/log"
FICHIER_RAPPORT="rapport_nettoyage.txt"

# 2. Vérification si bien en "sudo"
if [ "$EUID" -ne 0 ]; then
    echo "Erreur : Lance ce script avec sudo !"
    exit 1
fi

echo ""
echo "--- Préparation du nettoyage (Fichiers de plus de $JOURS jours) ---"
echo ""

# 3. Lister les fichiers et calculer la taille totale
# On cherche les fichiers finit par .log ou .gz
LISTE_FICHIERS=$(find $DOSSIER_LOGS -type f \( -name "*.log" -o -name "*.gz" \) -mtime +$JOURS)

if [ -z "$LISTE_FICHIERS" ]; then
    echo "Aucun fichier ancien trouvé."
    exit 0
fi

echo "Fichiers qui vont être supprimés :"
echo ""
echo "$LISTE_FICHIERS"
echo ""

# Calcul de la taille totale
TAILLE_TOTALE=$(du -ch $LISTE_FICHIERS | grep total$ | cut -f1)
echo "Espace total qui sera libéré : $TAILLE_TOTALE"
echo ""

# 4. Demande de confirmation
echo -n "Voulez-vous vraiment supprimer ces fichiers ? (oui/non) : "
read REPONSE

if [ "$REPONSE" != "oui" ]; then
    echo "Opération annulée."
    exit 0
fi

# 5. Suppression et création du rapport
echo "Suppression en cours..."
echo "Nettoyage du $(date)" > $FICHIER_RAPPORT
echo "Fichiers supprimés :" >> $FICHIER_RAPPORT
echo "$LISTE_FICHIERS" >> $FICHIER_RAPPORT

rm $LISTE_FICHIERS

echo ""
echo "--- TERMINÉ ---"
echo "Espace libéré : $TAILLE_TOTALE"
echo "Un rapport a été enregistré dans : $FICHIER_RAPPORT"