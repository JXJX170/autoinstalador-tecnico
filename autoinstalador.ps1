$apps = @{
    1 = @{ Name = "Office"; Url = "https://drive.google.com/uc?export=download&id=1F-FQAhzvykbl1su52aptz6PXUto0Vr6_"; Args = "/S" }
    2 = @{ Name = "Google Chrome"; Url = "https://drive.google.com/uc?export=download&id=1lig2GWyeLCwkuoXett8-3WOBH169qXTh"; Args = "/silent /install" }
    3 = @{ Name = "WinRAR"; Url = "https://drive.google.com/uc?export=download&id=1wNAAtxwfbP1Ed70P6TVGRZRlm3stXEmO"; Args = "/S" }
    4 = @{ Name = "Instalar TODOS"; Special = $true }
    0 = @{ Name = "Salir"; Exit = $true }
}

function Show-Menu {
    Clear-Host
    Write-Host "===============================" -ForegroundColor Gray
    Write-Host "[JXJ17X Scripting]" -ForegroundColor Red
    Write-Host "===============================" -ForegroundColor Gray
    Write-Host "===== Instalador Automático desde Google Drive =====" -ForegroundColor Cyan
    foreach ($key in $apps.Keys | Sort-Object) {
        Write-Host "$key. $($apps[$key].Name)"
    }
    Write-Host ""
    $selection = Read-Host "Selecciona el número de la app que quieres instalar"
    return [int]$selection
}

function Install-App($app) {
    $tempFile = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName() + ".exe")
    
    Write-Host "🌐 Descargando $($app.Name)..."
    Invoke-WebRequest -Uri $app.Url -OutFile $tempFile

    Write-Host "🚀 Instalando $($app.Name)..."
    Start-Process -FilePath $tempFile -ArgumentList $app.Args -Wait

    Remove-Item $tempFile -Force
    Write-Host "✅ $($app.Name) instalado.`n"
}

do {
    $choice = Show-Menu

    if ($apps.ContainsKey($choice)) {
        $app = $apps[$choice]

        if ($app.ContainsKey("Exit") -and $app.Exit) {
            Write-Host "👋 Cerrando instalador..." -ForegroundColor DarkGray
            break
        }

        if ($app.Special) {
            foreach ($k in $apps.Keys) {
                if (-not $apps[$k].Special -and -not $apps[$k].ContainsKey("Exit")) {
                    Install-App $apps[$k]
                }
            }
        } else {
            Install-App $app
        }

        Write-Host "`n¿Deseas instalar otra aplicación?" -ForegroundColor Yellow
        $again = Read-Host "Escribe 's' para volver al menú o cualquier otra tecla para salir"
    } else {
        Write-Host "❌ Opción inválida." -ForegroundColor Red
        $again = "s"
    }

} while ($again -eq "s")