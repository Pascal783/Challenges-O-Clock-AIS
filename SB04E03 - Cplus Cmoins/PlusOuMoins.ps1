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
    $tentatives++

    # Vérification de la validité
    if ($choix -as [int]) {
        $nombrePropose = [int]$choix

        if ($nombrePropose -eq $nombreMystere) {
            # 3. Message de victoire (Cyan)
            Write-Host ""
            Write-Host "🏆 FÉLICITATIONS ! 🏆" -ForegroundColor Cyan
            Write-Host "Tu as trouvé le nombre mystère $nombreMystere en $tentatives tentatives !" -ForegroundColor Cyan
            $trouve = $true
        }
        elseif ($nombrePropose -lt $nombreMystere) {
            # 4. Plus grand (Bleu) + Affichage tentative
            Write-Host "Nop! c'est plus! Essaie encore! (Essai n°$tentatives)" -ForegroundColor Blue
        }
        else {
            # 4. Plus petit (Vert) + Affichage tentative
            Write-Host "Nop! c'est moins! Essaie encore! (Essai n°$tentatives)" -ForegroundColor Green
        }
    }
    else {
        Write-Host "Erreur! : Met un nombre entre 1 et 100!" -ForegroundColor Red
        $tentatives-- # On ne compte pas une erreur de frappe comme une tentative
    }
}

# Pause finale
Write-Host ""
Write-Host "Appuyez sur une touche pour quitter le programme..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")