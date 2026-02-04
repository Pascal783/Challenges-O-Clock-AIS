#!/bin/bash

# 1. Vérifier si l'utilisateur est root
if [ "$EUID" -ne 0 ]; then
  echo "Veuillez lancer ce script avec sudo : sudo ./cleanup.sh"
  exit
fi

# Choix du nombre de jours avec vérification
echo ""
echo "--- CONFIGURATION DU NETTOYAGE ---"
echo ""
while true; do
    read -p "Supprimer les fichiers vieux de combien de jours ? : " JOURS
    
    # Vérifie si la saisie est un nombre entier (0 ou plus)
    if [[ "$JOURS" =~ ^[0-9]+$ ]]; then
        break # C'est un chiffre, on sort de la boucle
    else
        echo "Erreur : '$JOURS' n'est pas un nombre valide. Veuillez recommencer."
    fi
done

LOG_FILE="/var/log/cleanup.log"


# Gestion du mode force
FORCE=false
if [[ "$1" == "--force" || "$1" == "-f" ]]; then
    echo ""
    read -p "Voulez-vous vraiment supprimer les fichiers ? (o/n) : " CONFIRM < /dev/tty
    if [ "$CONFIRM" == "o" ]; then
        FORCE=true
    fi
fi

# 2. Afficher l'espace disque AVANT
echo ""
echo "--- ESPACE DISQUE AVANT NETTOYAGE ---"
echo ""
df -h / | grep / | awk '{ print "Espace utilisé : " $3 " sur " $2 }'
# On stocke l'espace libre en octets pour le calcul final
avant=$(df / | tail -1 | awk '{print $4}')

#  Message d'avertissement
if [ "$FORCE" = false ]; then
    echo ""
    echo -e "--- MODE SÉCURISÉ (Simulation) ---"
    echo ""
    echo "Aucun fichier ne sera supprimé. Utilisez -f pour nettoyer réellement."
fi

echo ""
echo -e "Nettoyage en cours..."
echo ""

# 3. Supprimer les fichiers dans /tmp plus vieux que $JOURS jours
nb_tmp=$(find /tmp -type f -mtime +$JOURS | wc -l)
if [ "$FORCE" = true ]; then
    find /tmp -type f -mtime +$JOURS -delete
    echo "$(date) : Nettoyage /tmp : $nb_tmp fichiers supprimés" >> "$LOG_FILE"
else
    find /tmp -type f -mtime +$JOURS -print
fi
echo "Statistiques : $nb_tmp fichiers trouvés."
echo ""

# 4. Supprimer les logs compressés (.gz) dans /var/log plus vieux que 30 jours
nb_logs=$(find /var/log -name "*.gz" -type f -mtime +30 | wc -l)
if [ "$FORCE" = true ]; then
    find /var/log -name "*.gz" -type f -mtime +30 -delete
    echo "$(date) : Nettoyage logs : $nb_logs fichiers .gz supprimés" >> "$LOG_FILE"
else
    find /var/log -name "*.gz" -type f -mtime +30 -print
fi
echo "Statistiques : $nb_logs fichiers trouvés."
echo""

# 5. Vider la corbeille de TOUS les utilisateurs
echo "> Vidage des corbeilles utilisateurs..."
taille_corbeille=$(du -sh /home/*/.local/share/Trash 2>/dev/null | awk '{print $1}' | head -n 1)
if [ "$FORCE" = true ]; then
    rm -rf /home/*/.local/share/Trash/*
    rm -rf /root/.local/share/Trash/*
    echo "$(date) : Corbeilles vidées (Taille : $taille_corbeille)" >> "$LOG_FILE"
else
    echo "Simulation : Suppression du contenu de /home/*/.local/share/Trash/*"
fi
echo "Statistiques : Environ $taille_corbeille à libérer."
echo ""

# 6. Nettoyer le cache APT
echo "> Nettoyage du cache des paquets (APT)..."
taille_apt=$(du -sh /var/cache/apt/archives | awk '{print $1}')
if [ "$FORCE" = true ]; then
    apt-get clean
    echo "$(date) : Cache APT nettoyé ($taille_apt)" >> "$LOG_FILE"
else
    echo "Simulation : apt-get clean (serait exécuté)"
fi
echo "Statistiques : $taille_apt de cache APT trouvé."
echo ""

# 7. Afficher l'espace disque APRÈS
echo -e "--- RÉSULTAT ---"
apres=$(df / | tail -1 | awk '{print $4}')
echo ""

# Calcul simple de la différence
gain=$(( (apres - avant) / 1024 ))

df -h / | grep / | awk '{ print "Espace utilisé après : " $3 " sur " $2 }'

# Affichage du gain uniquement si FORCE est vrai
if [ "$FORCE" = true ]; then
    echo "Espace récupéré : $gain Mo"
    echo "$(date) : Gain total de $gain Mo" >> "$LOG_FILE"
else
    echo "Espace récupéré : 0 Mo (Mode simulation)"
fi
echo ""

echo -e "Système nettoyé ! (Logs consultables dans $LOG_FILE)"
echo ""