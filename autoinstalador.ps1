function Download-FromDrive {
    param(
        [string]$id,
        [string]$output
    )

    $confirmUrl = "https://drive.google.com/uc?export=download&id=$id"
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $initial = Invoke-WebRequest -Uri $confirmUrl -WebSession $session

    if ($initial.Content -match 'confirm=([0-9A-Za-z_]+)') {
        $confirmCode = $matches[1]
        $downloadUrl = "https://drive.google.com/uc?export=download&confirm=$confirmCode&id=$id"
        Invoke-WebRequest -Uri $downloadUrl -OutFile $output -WebSession $session
    } else {
        Invoke-WebRequest -Uri $confirmUrl -OutFile $output
    }
}

$apps = @{
    1 = @{ Name = "Office"; ID = "1F-FQAhzvykbl1su52aptz6PXUto0Vr6_"; Args = "/S" }
    2 = @{ Name = "Google Chrome"; ID = "1lig2GWyeLCwkuoXett8-3WOBH169qXTh"; Args = "/silent /install" }
    3 = @{ Name = "WinRAR"; ID = "1wNAAtxwfbP1Ed70P6TVGRZRlm3stXEmO"; Args = "/S" }
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
    try {
        Download-FromDrive -id $app.ID -output $tempFile
    } catch {
        Write-Host "❌ Error al descargar $($app.Name)" -ForegroundColor Red
        return
    }

    # Verificar si el archivo descargado es válido
    $size = (Get-Item $tempFile).Length
    if ($size -lt 100000) {
        Write-Host "⚠️ El archivo descargado parece inválido o demasiado pequeño. Verifica el enlace." -ForegroundColor Yellow
        return
    }

    Write-Host "🚀 Instalando $($app.Name)..."
    try {
        Start-Process -FilePath $tempFile -ArgumentList $app.Args -Wait
        Write-Host "✅ $($app.Name) instalado.`n"
    } catch {
        Write-Host "❌ Error al ejecutar el instalador de $($app.Name)." -ForegroundColor Red
    } finally {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
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