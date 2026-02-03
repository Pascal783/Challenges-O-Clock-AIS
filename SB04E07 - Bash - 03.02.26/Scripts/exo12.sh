#!/bin/bash

# 1. Vérification des arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source> <destination>"
    exit 1
fi

SOURCE=$1
DESTINATION=$2

# 2. Vérification si les dossiers existent
if [ ! -d "$SOURCE" ]; then
    echo "Erreur : Le dossier source '$SOURCE' n'existe pas."
    exit 1
fi

# 3 VERIFICATION ET INSTALLATION DE RSYNC
if ! command -v rsync >/dev/null 2>&1; then
    echo "rsync n'est pas installé. Tentative d'installation..."
    # Vérification si bien en "sudo"
    if [ "$EUID" -ne 0 ]; then
        echo "Erreur : rsync est manquant et vous n'êtes pas root. Relancez avec sudo."
        exit 1
    fi
    apt-get update && apt-get install -y rsync
    if [ $? -ne 0 ]; then
        echo "Erreur : L'installation de rsync a échoué."
        exit 1
    fi
    echo "rsync a été installé avec succès."
fi

# Création du dossier de destination s'il n'existe pas
if [ ! -d "$DESTINATION" ]; then
    echo "Le dossier destination n'existe pas, création en cours..."
    mkdir -p "$DESTINATION"
fi

echo "--- DÉBUT DE LA SYNCHRONISATION ---"
echo "Source      : $SOURCE"
echo "Destination : $DESTINATION"
echo ""

# 3. Synchronisation avec rsync
# -a : archive (garde les dates, les permissions)
# -v : verbose (affiche les fichiers copiés)
# -z : compression (plus rapide pour le transfert)
# --delete : (Bonus) supprime dans destination ce qui n'est plus dans source
# --stats : affiche le résumé (taille, fichiers)

rsync -avz --delete --stats "$SOURCE/" "$DESTINATION/"

# 4. Gestion des erreurs
if [ $? -eq 0 ]; then
    echo ""
    echo "--- RÉUSSITE ---"
    echo "La synchronisation s'est terminée sans erreur."
else
    echo ""
    echo "--- ERREUR ---"
    echo "Un problème est survenu pendant la copie."
    echo "Vérifiez les permissions ou l'espace disque."
fi