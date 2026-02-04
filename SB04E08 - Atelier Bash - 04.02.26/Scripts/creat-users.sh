#!/bin/bash

# Vérifier que le script est lancé avec sudo
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être lancé avec sudo."
    exit 1
fi

# Vérifier si l'utilisateur a donné un fichier en argument
if [ -z "$1" ]; then
    echo "Usage: sudo $0 fichier.csv"
    exit 1
fi

# Variables
FICHIER=$1
LOG_FILE="/var/log/user-creation.log"
RECAP_FILE="users_created.txt"

# Menu de création ou suppression d'utilisateur
echo""
echo "---------------------------------------------"
echo "    Création ou suppresion d'utilisateurs    "
echo "---------------------------------------------"
echo ""
echo "Que souhaitez-vous faire ?"
echo ""
echo "1) Créer les utilisateurs du fichier CSV"
echo "2) Supprimer les utilisateurs du fichier CSV"
read -p "Votre choix (1 ou 2) : " CHOIX

#-------------------------------------------
# Choix 1 : Création des Utilisateurs
#-------------------------------------------
if [ "$CHOIX" == "1" ]; then
    # Préparer les fichiers (touch crée le fichier s'il n'existe pas)
    touch "$LOG_FILE"
    echo "--- Création du $(date) ---" > "$RECAP_FILE"

    echo ""
    echo "Début du traitement... (Consultez $LOG_FILE pour les détails)"

    # On boucle sur chaque ligne du fichier CSV
    # On saute la première ligne (le titre) avec 'tail -n +2'
    tail -n +2 "$FICHIER" | while IFS=',' read -r prenom nom departement fonction
    do

        # Nettoyage des espaces (au cas où le CSV soit mal formé)
        prenom=$(echo "$prenom" | xargs)
        nom=$(echo "$nom" | xargs)
        departement=$(echo "$departement" | xargs)

        # 1. Préparation du Login (1ère lettre prénom + nom en minuscules)
        # On utilise tr pour tout mettre en minuscule
        PREMIERE_LETTRE=$(echo "${prenom:0:1}" | tr '[:upper:]' '[:lower:]')
        NOM_MIN=$(echo "$nom" | tr '[:upper:]' '[:lower:]')
        LOGIN="${PREMIERE_LETTRE}${NOM_MIN}"

        # 2. VÉRIFICATION si l'utilisateur existe déjà
        echo ""
        if id "$LOGIN"; then
            echo ""
            echo "$(date) : L'utilisateur $LOGIN existe déjà." >> "$LOG_FILE"
            echo "L'utilisateur $LOGIN existe déjà."
            continue # On passe à la ligne suivante du CSV
        fi

        # 3. CRÉATION DU GROUPE s'il n'existe pas
        if ! getent group "$departement"; then
            groupadd "$departement" && echo "$(date) : Groupe $departement créé." >> "$LOG_FILE"
            echo "Groupe $departement créé."
            echo ""
        fi

        # 4. Génération d'un mot de passe aléatoire (8 caractères)
        MDP=$(openssl rand -base64 12 | head -c 8)

        # 5. Création de l'utilisateur
        # -m : crée le répertoire perso /home/login
        # -g : définit le groupe principal (département)
        # -c : ajoute le nom complet en commentaire
        useradd -m -g "$departement" -c "$prenom $nom" "$LOGIN" 2>> "$LOG_FILE"

        # Vérifier si l'utilisateur a bien été créé
        if [ $? -eq 0 ]; then
            # On définit le mot de passe
            echo "$LOGIN:$MDP" | chpasswd

            # Remplissage du fichier récapitulatif
            echo "Login: $LOGIN | MDP: $MDP | Nom: $prenom $nom" >> "$RECAP_FILE"

            # Log de l'opération réussie
            echo "$(date) : SUCCESS - Utilisateur $LOGIN créé." >> "$LOG_FILE"
            
            # 5. Affichage du résultat
            echo ""
            echo "------------------------------------------"
            echo "Utilisateur : $prenom $nom"
            echo "Login       : $LOGIN"
            echo "Groupe      : $departement"
            echo "Mot de passe: $MDP (Sauvegardé dans $RECAP_FILE)"
            echo "------------------------------------------"
        else
            echo ""
            echo "$(date) : ERROR - Échec de création pour $LOGIN" >> "$LOG_FILE"
            echo "Erreur : L'utilisateur $LOGIN existe peut-être déjà. (voir $LOG_FILE)"
            echo "------------------------------------------"
        fi

    done

#-------------------------------------------
# Choix 2 : Suppression des Utilisateurs
#-------------------------------------------
elif [ "$CHOIX" == "2" ]; then
    echo ""
    echo "--- Phase de Suppression ---"
    echo ""
    
    tail -n +2 "$FICHIER" | while IFS=',' read -r prenom nom departement fonction
    do
        # On reconstruit le login pour savoir qui supprimer
        prenom=$(echo "$prenom" | xargs)
        nom=$(echo "$nom" | xargs)
        PREMIERE_LETTRE=$(echo "${prenom:0:1}" | tr '[:upper:]' '[:lower:]')
        NOM_MIN=$(echo "$nom" | tr '[:upper:]' '[:lower:]')
        LOGIN="${PREMIERE_LETTRE}${NOM_MIN}"

        # On vérifie si l'utilisateur existe avant de demander
        if id "$LOGIN"; then
            echo ""
            echo "------------------------------------------"
            echo ""
            read -p "Supprimer l'utilisateur $LOGIN ($prenom $nom) ? [o/N] : " CONFIRM < /dev/tty
            
            if [[ "$CONFIRM" == "o" || "$CONFIRM" == "O" ]]; then
                # -r supprime aussi le dossier /home/utilisateur
                userdel -r "$LOGIN" 2>> "$LOG_FILE"
                if [ $? -eq 0 ]; then
                    echo "$(date) : DELETE - Utilisateur $LOGIN supprimé." >> "$LOG_FILE"
                    echo "$LOGIN a été supprimé."
                    echo ""
                else
                    echo "Erreur lors de la suppression de $LOGIN." >> "$LOG_FILE"
                    echo ""
                fi
            else
                echo "Action annulée pour $LOGIN."
                echo ""
            fi
        else
            echo "Ignoré : $LOGIN n'existe pas sur le système."
            echo ""
        fi
    done

else
    echo "Choix invalide. Fin du script."
    exit 1
fi

echo ""
echo "Terminé ! Logs : $LOG_FILE | Récap : $RECAP_FILE"
echo ""
echo "------------------------------------------"