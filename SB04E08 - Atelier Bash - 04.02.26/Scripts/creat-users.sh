#!/bin/bash

# Vérifier si l'utilisateur a donné un fichier en argument
if [ -z "$1" ]; then
    echo "Usage: sudo $0 fichier.csv"
    exit 1
fi

FICHIER=$1

# On boucle sur chaque ligne du fichier CSV
# On saute la première ligne (le titre) avec 'tail -n +2'
tail -n +2 "$FICHIER" | while IFS=',' read -r prenom nom departement fonction
do
    # 1. Préparation du Login (1ère lettre prénom + nom en minuscules)
    # On utilise tr pour tout mettre en minuscule
    PREMIERE_LETTRE=$(echo "${prenom:0:1}" | tr '[:upper:]' '[:lower:]')
    NOM_MIN=$(echo "$nom" | tr '[:upper:]' '[:lower:]')
    LOGIN="${PREMIERE_LETTRE}${NOM_MIN}"

    # 2. Création du groupe
    echo""
    groupadd "$departement"
    echo""

    # 3. Génération d'un mot de passe aléatoire (8 caractères)
    MDP=$(openssl rand -base64 12 | head -c 8)

    # 4. Création de l'utilisateur
    # -m : crée le répertoire perso /home/login
    # -g : définit le groupe principal (département)
    # -c : ajoute le nom complet en commentaire
    useradd -m -g "$departement" -c "$prenom $nom" "$LOGIN"

    # Vérifier si l'utilisateur a bien été créé
    if [ $? -eq 0 ]; then
        # On définit le mot de passe
        echo "$LOGIN:$MDP" | chpasswd
        
        # 5. Affichage du résultat
        echo "------------------------------------------"
        echo "Utilisateur : $prenom $nom"
        echo "Login       : $LOGIN"
        echo "Groupe      : $departement"
        echo "Mot de passe: $MDP"
        echo "------------------------------------------"
    else
        echo "Erreur : L'utilisateur $LOGIN existe peut-être déjà."
        echo "------------------------------------------"
    fi

done

echo ""
echo "Terminé !"
echo "------------------------------------------"