#!/bin/bash

# Fichier contenant la liste des paquets
LISTE="paquets.txt"
RAPPORT="rapport_installation.txt"

# Vérifier si le fichier liste existe
if [ ! -f "$LISTE" ]; then
    echo "Le fichier $LISTE est introuvable !"
    exit 1
fi

# Vérification si bien en "sudo"
if [ "$EUID" -ne 0 ]; then
    echo "Lance ce script avec sudo !"
    exit 1
fi

# --- Mise à jour des dépôts ---
echo ""
echo "Mise à jour de la liste des paquets (apt update)..."
# Correction : on enlève la redirection pour voir si les dépôts sont accessibles
apt update -y 
if [ $? -eq 0 ]; then
    echo "Mise à jour réussie."
else
    echo "Attention : Échec de la mise à jour des dépôts."
fi

# Initialisation du rapport
echo "Rapport d'installation du $(date)" > $RAPPORT
echo "-----------------------------------" >> $RAPPORT
TOTAL=$(wc -l < "$LISTE")
COURANT=0

echo ""
echo "Début de l'analyse ($TOTAL paquets à vérifier)..."
echo ""

while read -r PAQUET; do
    # Ignorer les lignes vides
    [ -z "$PAQUET" ] && continue
    
    COURANT=$((COURANT + 1))
    echo "[$COURANT/$TOTAL] Vérification de : $PAQUET"

    if dpkg -l | grep -q "^ii  $PAQUET "; then
        echo "--> Déjà installé."
        echo "$PAQUET : Déjà présent" >> $RAPPORT
    else
        echo -n "--> $PAQUET n'existe pas. On l'installe ? (o/n) : "
        # On force la lecture depuis le clavier
        read -r REPONSE < /dev/tty
        
        if [ "$REPONSE" == "o" ]; then
            echo "Installation de $PAQUET en cours..."
            # Correction : on retire le masquage pour voir l'erreur ici
            if apt install -y "$PAQUET"; then
                echo "OK : $PAQUET installé avec succès."
                echo "$PAQUET : INSTALLÉ" >> $RAPPORT
            else
                echo "ERREUR : Impossible d'installer $PAQUET."
                echo "$PAQUET : ERREUR" >> $RAPPORT
            fi
        else
            echo "Ignoré."
            echo "$PAQUET : IGNORÉ" >> $RAPPORT
        fi
    fi
    echo ""
done < "$LISTE"

echo "--- TERMINÉ ---"
echo ""
echo "Consulte '$RAPPORT' pour voir le détail."
echo ""