# Configuration pour les accents
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "       JEU DU NOMBRE MYSTÈRE (1-100)      " -ForegroundColor cyan
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""

# 1. Générer un nombre aléatoire entre 1 et 100
$nombreMystere = Get-Random -Minimum 1 -Maximum 101
$tentatives = 0
$trouve = $false

# Boucle de jeu
while (-not $trouve) {
    # 2. Demander au joueur de proposer un nombre
    $choix = Read-Host "Quel est le nombre mystère?"
    $tentatives++

    # Vérifier si l'entrée est bien un nombre
    if ($choix -as [int]) {
        $nombrePropose = [int]$choix

        # 3. Comparer la proposition
        if ($nombrePropose -eq $nombreMystere) {
            # 5. Victoire !
            Write-Host ""
            Write-Host "Bravo! Tu as trouvé le nombre mystère $nombreMystere !" -ForegroundColor Green 
            Write-Host "Nombre de tentatives : $tentatives" -ForegroundColor White
            $trouve = $true
        }
        elseif ($nombrePropose -lt $nombreMystere) {
            # 4. Plus grand
            Write-Host "Nop! c'est plus! Essaie encore!" -ForegroundColor Red
        }
        else {
            # 4. Plus petit
            Write-Host "Nop! c'est moins! Essaie encore!" -ForegroundColor Blue
        }
    }
    else {
        Write-Host "Erreur : Met un nombre entre 1 et 100" -ForegroundColor DarkRed
    }
}

# 6. Pause à la fin
Write-Host ""
Write-Host "Appuyez sur une touche pour quitter..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")