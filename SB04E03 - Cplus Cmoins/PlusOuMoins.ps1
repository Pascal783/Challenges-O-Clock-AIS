# Configuration pour les accents
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 1. Titre
Write-Host "**********************************************" -ForegroundColor Cyan   
Write-Host "    BIENVENUE AU JEU DU C'EST + OU C'EST -    " -ForegroundColor Red
Write-Host "**********************************************" -ForegroundColor Cyan
Write-Host ""

# 2. Message d'accueil et règles
Write-Host "[RÈGLES DU JEU]" -ForegroundColor Yellow
Write-Host "Trouves le nombre mystère entre 1 et 100." -ForegroundColor Yellow
Write-Host "Le but est de le trouver en un minimum d'essais!" -ForegroundColor Yellow
Write-Host "----------------------------------------------" -ForegroundColor Yellow
Write-Host ""

# Génération du nombre mystère
$nombreMystere = Get-Random -Minimum 1 -Maximum 101
$tentatives = 0
$trouve = $false

# Boucle de jeu
while (-not $trouve) {
    # Demander au joueur de proposer un nombre
    $choix = Read-Host "Quel est le nombre mystère?"
    
    # --- VÉRIFICATION DE LA SAISIE ---
    
    # A. Vérifier que c'est bien un nombre
    if ($choix -as [int]) {
        $nombrePropose = [int]$choix

        # B. Vérifier que le nombre est entre 1 et 100
        if ($nombrePropose -lt 1 -or $nombrePropose -gt 100) {
            Write-Host "Erreur : Le nombre doit être compris entre 1 et 100 !" -ForegroundColor Red
            # On ne fait rien d'autre, la boucle recommence sans incrémenter $tentatives
        }
        else {
            # Si tout est OK, on compte la tentative
            $tentatives++

            # Comparaison
            if ($nombrePropose -eq $nombreMystere) {
                Write-Host ""
                Write-Host "🏆 FÉLICITATIONS ! 🏆" -ForegroundColor Cyan
                Write-Host "Tu as trouvé le nombre mystère $nombreMystere en $tentatives tentatives !" -ForegroundColor Cyan
                $trouve = $true
            }
            elseif ($nombrePropose -lt $nombreMystere) {
                Write-Host "Nop! c'est plus! Essaie encore! (Essai n°$tentatives)" -ForegroundColor Blue
            }
            else {
                Write-Host "Nop! c'est moins! Essaie encore! (Essai n°$tentatives)" -ForegroundColor Green
            }
        }
    }
    else {
        # Message d'erreur si ce n'est pas un nombre (texte, vide, etc.)
        Write-Host "Erreur : Saisie invalide ! Entre un NOMBRE entre 1 et 100." -ForegroundColor Red
    }
}

# Pause finale
Write-Host ""
Write-Host "Appuyez sur une touche pour quitter le programme..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")