#!/bin/bash

# 1. Variables
SOURCE=$1
DEST="/home/administrateur/Documents/backup"
DATE=$(date +%Y%m%d_%H%M%S)
NOM_FICHIER="backup_$DATE.tar.gz"
LOG="/var/log/backup.log"

# 2. Vérification d'un dossier en argument
if [ -z "$1" ]; then
    echo ""
    echo "Usage: $0 <chemin du dossier à sauvegarder>"
    echo ""
    exit 1
fi

if [ ! -d "$SOURCE" ]; then
    echo ""
    echo "Erreur : Le répertoire source '$SOURCE' n'existe pas." | tee -a "$LOG"
    echo ""
    exit 1
fi

# 3. Créer le dossier de destination s'il n'existe pas
if [ ! -d "$DEST" ]; then
    echo ""
    echo "Création du dossier $DEST..."
    echo ""
    mkdir -p "$DEST"
fi

# 4. Vérification espace disque dispo
DISPO=$(df "$DEST" | awk 'NR==2 {print $4}')
TAILLE_SOURCE=$(du -s "$SOURCE" | awk '{print $1}')

if [ "$TAILLE_SOURCE" -gt "$DISPO" ]; then
    echo "ERREUR : Espace disque insuffisant sur $DEST." >> "$LOG"
    exit 1
fi

# 5. Création de l'archive tar.gz
# -z : compresser (gzip) / -c : créer / -f : fichier
tar -czf "$DEST/$NOM_FICHIER" "$SOURCE"

# 6. Message de confirmation et taille archive
if [ $? -eq 0 ]; then
    TAILLE=$(du -h "$DEST/$NOM_FICHIER" | cut -f1)
    echo "-------------------------------------------"
    echo ""
    echo "Sauvegarde créée : $DEST/$NOM_FICHIER"
    echo "Taille de l'archive : $TAILLE"
    echo "Log: $LOG"
    echo ""
    echo "-------------------------------------------"
    echo "Sauvegarde créée : $DEST/$NOM_FICHIER" >> "$LOG"
    echo "Taille de l'archive : $TAILLE" >> "$LOG"
else
    echo "--------------------------------------------"
    echo ""
    echo "Erreur lors de la création de la sauvegarde."
    echo "Log: $LOG"
    echo ""
    echo "--------------------------------------------"
    echo "Erreur lors de la création de la sauvegarde."  >> "$LOG"
fi

# 7. ROTATION : Garder les 7 dernières sauvegardes
echo ""
echo "Vérification de la rotation des sauvegardes..."

# On compte combien il y a de fichiers backup_*.tar.gz
NB_FICHIERS=$(ls -1 "$DEST"/backup_*.tar.gz | wc -l)

if [ "$NB_FICHIERS" -gt 7 ]; then
    # On calcule combien on doit en supprimer
    A_SUPPRIMER=$((NB_FICHIERS - 7))
    
    # La commande 'ls -t' trie par date (plus récent au plus vieux)
    # 'tail -n' récupère les derniers (donc les plus vieux)
    # 'xargs rm' les supprime
    ls -1t "$DEST"/backup_*.tar.gz | tail -n "$A_SUPPRIMER" | xargs rm
    
    echo ""
    echo "Rotation effectuée : $A_SUPPRIMER ancienne(s) sauvegarde(s) supprimée(s)." | tee -a "$LOG"
    echo ""
else
    echo ""
    echo "Rotation : Moins de 7 sauvegardes présentes, rien à supprimer."
    echo ""
fi