#!/bin/bash

# 1. Nom du fichier de sortie
FICHIER_HTML="rapport_systeme.html"

echo "Génération du rapport en cours..."

# 2. Début du fichier HTML et Styles CSS (pour faire joli)
cat <<EOF > $FICHIER_HTML
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Rapport Système - $(hostname)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f4; }
        h1 { color: #333; border-bottom: 2px solid #333; }
        h2 { color: #0056b3; margin-top: 30px; }
        pre { background: #eee; padding: 15px; border-radius: 5px; overflow-x: auto; }
        .info { color: #666; font-style: italic; }
    </style>
</head>
<body>
    <h1>Rapport État Système : $(hostname)</h1>
    <p class="info">Généré le : $(date)</p>
EOF

# 3. Informations Système
echo "<h2>Système et Version</h2><pre>$(lsb_release -d | cut -f2-)</pre>" >> $FICHIER_HTML

# 4. CPU et Mémoire
echo "<h2>Utilisation CPU et Mémoire</h2><pre>" >> $FICHIER_HTML
echo "Mémoire vive (RAM) :" >> $FICHIER_HTML
free -h >> $FICHIER_HTML
echo -e "\nCharge CPU (dernières minutes) :" >> $FICHIER_HTML
uptime | awk -F'load average:' '{ print $2 }' >> $FICHIER_HTML
echo "</pre>" >> $FICHIER_HTML

# 5. Espace Disque
echo "<h2>Espace Disque</h2><pre>$(df -h | grep '^/')" >> $FICHIER_HTML
echo "</pre>" >> $FICHIER_HTML

# 6. Services Actifs (Top 10)
echo "<h2>Services en cours d'exécution (Top 10)</h2><pre>" >> $FICHIER_HTML
systemctl list-units --type=service --state=running | head -n 12 >> $FICHIER_HTML
echo "</pre>" >> $FICHIER_HTML

# 7. Dernières Connexions
echo "<h2>Dernières connexions utilisateurs</h2><pre>$(last -n 5)" >> $FICHIER_HTML
echo "</pre>" >> $FICHIER_HTML

# 8. Fin du fichier
echo "</body></html>" >> $FICHIER_HTML

echo "Succès ! Le rapport est prêt."

# 9. Ouvrir le rapport (Spécifique à Windows/WSL)
if command -v explorer.exe > /dev/null; then
    explorer.exe $FICHIER_HTML
fi