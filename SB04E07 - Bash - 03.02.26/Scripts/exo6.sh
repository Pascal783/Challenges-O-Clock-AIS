#!/bin/bash

# 1. Vérification si bien en "sudo"
if [ "$EUID" -ne 0 ]; then
  echo "Lance ce script avec sudo !"
  exit
fi

# 2. Affichage de l'état des services
echo ""
echo "--- ÉTAT DES SERVICES ---"
echo ""
echo -n "SSH : "
systemctl is-active ssh
echo ""
echo -n "CRON (Tâches planifiées) : "
systemctl is-active cron
echo ""
echo -n "SERVEUR WEB (Nginx/Apache) : "
systemctl is-active nginx || systemctl is-active apache2
echo ""
echo "----------------------------"
echo ""
# 3. Menu pour l'utilisateur
echo "MENU D'ACTION"
echo ""
echo "1) Démarrer un service"
echo "2) Arrêter un service"
echo "3) Quitter"
read CHOIX

# 4. Action selon le choix
if [ "$CHOIX" -eq 1 ]; then
    echo "Quel service démarrer ? (ssh, cron, nginx ou apache2)"
    read SERVICE
    systemctl start "$SERVICE"
    echo "Tentative de démarrage de $SERVICE effectuée !"

elif [ "$CHOIX" -eq 2 ]; then
    echo "Quel service arrêter ? (ssh, cron, nginx ou apache2)"
    read SERVICE
    systemctl stop "$SERVICE"
    echo "Tentative d'arrêt de $SERVICE effectuée !"

else
    echo "Fermeture du programme."
    exit
fi

# 5. On réaffiche l'état final pour confirmer
echo "Nouvel état de $SERVICE :"
systemctl is-active "$SERVICE"