#!/bin/bash

BASEDIR=$(dirname "$0")

# --- 1. CONFIGURATION et COULEURS ---
VERSION="1.0"
AUTEUR="Pascal ROBERT"
LOG_FILE="$BASEDIR/sysadmin_activity.log"

VERT='\033[0;32m'
ROUGE='\033[0;31m'
JAUNE='\033[1;33m'
CYAN='\033[0;36m'
BLEU='\033[0;34m'
NC='\033[0m' # Pas de couleur

# --- 2. FONCTIONS UTILITAIRES ---

# Fonction pour logger l'activité
log_activity() {
    local ACTION=$1
    local DATE=$(date "+%Y-%m-%d %H:%M:%S")
    local USER=$(whoami)
    echo "[$DATE] User: $USER - Action: $ACTION" >> "$LOG_FILE"
}

# Fonction pour afficher l'aide
afficher_aide() {
    clear
    echo -e "${JAUNE}--- AIDE & DOCUMENTATION ---${NC}"
    echo -e "${VERT}1. Sauvegarde :${NC} Archive un dossier précis."
    echo -e "${VERT}2. Monitoring :${NC} Affiche l'état CPU/RAM."
    echo -e "${VERT}3. Utilisateurs :${NC} Crée des comptes via un fichier CSV."
    echo -e "${VERT}4. Nettoyage :${NC} Vide cache et logs (-f pour forcer)."
    echo -e "${VERT}5. Services :${NC} Vérifie l'état des services."
}

# Fonction pour faire une pause
attendre() {
    echo -e "\n${JAUNE}Appuyez sur Entrée pour revenir au menu...${NC}"
    read
}

# --- 3. VÉRIFICATION AVANT DÉMARRAGE ---
# On vérifie que tous les scripts sont là, sinon on ne lance pas le menu
for script in "backup.sh" "monitor.sh" "creat-users.sh" "cleanup.sh" "check-service.sh"; do
    if [ ! -f "$BASEDIR/$script" ]; then
        echo -e "${ROUGE}ERREUR CRITIQUE : Le fichier $script est manquant !${NC}"
        exit 1
    fi
done

# --- 4. BOUCLE DU MENU ---
while true; do
    clear
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}      OUTILS D'ADMINISTRATION v$VERSION   ${NC}"
    echo -e "${CYAN}        (Créé par $AUTEUR)            ${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo -e "1. Sauvegarde de répertoire"
    echo -e "2. Monitoring système"
    echo -e "3. Créer des utilisateurs"
    echo -e "4. Nettoyage système"
    echo -e "5. Vérifier les services"
    echo -e "6. ${JAUNE}Aide / Documentation${NC}"
    echo -e "7. Quitter"
    echo ""
    echo -e "${CYAN}========================================${NC}"
    
    read -p "Votre choix : " CHOIX

    case $CHOIX in
        1)
            log_activity "Lancement Sauvegarde"
            # backup.sh a besoin d'un dossier source ($1)
            if [ -f "$BASEDIR/backup.sh" ]; then
                echo ""
                echo "--- Lancement de la sauvegarde ---"
                read -p "Quel dossier voulez-vous sauvegarder ? (ex: /home/user) : " DOSSIER_SOURCE
                sudo bash "$BASEDIR/backup.sh" "$DOSSIER_SOURCE"
            else
                echo -e "${ROUGE}Erreur : backup.sh est introuvable.${NC}"
            fi
            attendre
            ;;
        2)            
            log_activity "Lancement Monitoring"
            if [ -f "$BASEDIR/monitor.sh" ]; then
                bash "$BASEDIR/monitor.sh"
            else
                echo -e "${ROUGE}Erreur : monitor.sh est introuvable.${NC}"
            fi
            attendre
            ;;
        3)
            log_activity "Gestion Utilisateurs"
            # creat-users.sh a besoin d'un fichier CSV ($1)
            if [ -f "$BASEDIR/creat-users.sh" ]; then
                echo ""
                echo "--- Gestion des utilisateurs ---"
                read -p "Chemin du fichier CSV à utiliser : " FICHIER_CSV
                # On lance avec sudo car creat-users.sh vérifie si on est root
                sudo bash "$BASEDIR/creat-users.sh" "$FICHIER_CSV"
            else
                echo -e "${ROUGE}Erreur : creat-users.sh est introuvable.${NC}"
            fi
            attendre
            ;;
        4)
            log_activity "Lancement Nettoyage"
            # cleanup.sh gère l'option -f
            if [ -f "$BASEDIR/cleanup.sh" ]; then
                echo ""
                read -p "Voulez-vous forcer le nettoyage (pas de simulation) ? (o/n) : " FORCE
                if [ "$FORCE" == "o" ]; then
                    sudo bash "$BASEDIR/cleanup.sh" -f
                else
                    sudo bash "$BASEDIR/cleanup.sh"
                fi
            else
                echo -e "${ROUGE}Erreur : cleanup.sh est introuvable.${NC}"
            fi
            attendre
            ;;
        5)
            log_activity "Vérification Services"
            if [ -f "$BASEDIR/check-service.sh" ]; then
                sudo bash "$BASEDIR/check-service.sh"
            else
                echo -e "${ROUGE}Erreur : check-service.sh est introuvable.${NC}"
            fi
            attendre
            ;;
        6)
            log_activity "Consultation Aide"
            afficher_aide
            attendre
            ;;
        7)
            log_activity "Fermeture Script"
            echo -e "${VERT}Fermeture du menu.${NC}"
            exit 0
            ;;
        *)
            echo -e "${ROUGE}Choix invalide. Veuillez choisir entre 1 et 7.${NC}"
            sleep 2
            ;;
    esac
done