#!/bin/bash

BASEDIR=$(dirname "$0")

# --- 1. COULEURS ---
VERT='\033[0;32m'
ROUGE='\033[0;31m'
JAUNE='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Pas de couleur

# Fonction pour faire une pause avant de revenir au menu
attendre() {
    echo -e "\n${JAUNE}Appuyez sur Entrée pour revenir au menu...${NC}"
    read
}

# --- 2. BOUCLE DU MENU ---
while true; do
    clear
    echo ""
    echo -e "${CYAN}=================================${NC}"
    echo -e "${CYAN}     OUTILS D'ADMINISTRATION     ${NC}"
    echo -e "${CYAN}=================================${NC}"
    echo ""
    echo -e "1. Sauvegarde de répertoire"
    echo -e "2. Monitoring système"
    echo -e "3. Créer des utilisateurs"
    echo -e "4. Nettoyage système"
    echo -e "5. Vérifier les services"
    echo -e "6. Quitter"
    echo ""
    echo -e "${CYAN}=================================${NC}"
    
    read -p "Votre choix : " CHOIX

    case $CHOIX in
        1)
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
            if [ -f "$BASEDIR/monitor.sh" ]; then
                bash "$BASEDIR/monitor.sh"
            else
                echo -e "${ROUGE}Erreur : monitor.sh est introuvable.${NC}"
            fi
            attendre
            ;;
        3)
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
            
            if [ -f "$BASEDIR/check-service.sh" ]; then
                sudo bash "$BASEDIR/check-service.sh"
            else
                echo -e "${ROUGE}Erreur : check-service.sh est introuvable.${NC}"
            fi
            attendre
            ;;
        6)
            echo -e "${VERT}Fermeture du menu.${NC}"
            exit 0
            ;;
        *)
            echo -e "${ROUGE}Choix invalide. Veuillez choisir entre 1 et 6.${NC}"
            sleep 2
            ;;
    esac
done