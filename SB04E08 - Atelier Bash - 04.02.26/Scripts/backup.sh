#!/bin/bash

# 1. Vérification d'un dossier en argument
if [ -z "$1" ]; then
    echo ""
    echo "Usage: $0 <chemin du dossier à sauvegarder>"
    exit 1
fi

# 2. Variables
SOURCE=$1
DEST="/home/administrateur/Documents/backup"
DATE=$(date +%Y%m%d_%H%M%S)
NOM_FICHIER="backup_$DATE.tar.gz"

# 3. Créer le dossier de destination s'il n'existe pas
if [ ! -d "$DEST" ]; then
    echo ""
    echo "Création du dossier $DEST..."
    echo ""
    mkdir -p "$DEST"
fi

# 4. Création de l'archive tar.gz
# -z : compresser (gzip) / -c : créer / -f : fichier
tar -czf "$DEST/$NOM_FICHIER" "$SOURCE"

# 5. Message de confirmation et taille archive
if [ $? -eq 0 ]; then
    TAILLE=$(du -h "$DEST/$NOM_FICHIER" | cut -f1)
    echo "-------------------------------------------"
    echo ""
    echo "Sauvegarde créée : $DEST/$NOM_FICHIER"
    echo "Taille de l'archive : $TAILLE"
    echo ""
    echo "-------------------------------------------"
else
    echo "--------------------------------------------"
    echo ""
    echo "Erreur lors de la création de la sauvegarde."
    echo ""
    echo "--------------------------------------------"
fi