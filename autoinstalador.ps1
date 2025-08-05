$installerPath = "C:\Instaladores"

$apps = @{
    1 = @{ Name = "Google Chrome"; File = "chrome.exe"; Args = "/silent /install" }
    2 = @{ Name = "WinRAR"; File = "winrar-x64-701es"; Args = "/S" }
    3 = @{ Name = "Office 365"; SubFolder = "Office"; File = "setup.exe"; Args = "/configure config.xml" }
    4 = @{ Name = "Instalar Todos"; Special = $true }
}

function Show-Menu {
    Clear-Host
    Write-Host "===== Instalador Automático desde Carpeta Local =====" -ForegroundColor Cyan
    foreach ($key in $apps.Keys) {
        Write-Host "$key. $($apps[$key].Name)"
    }
    Write-Host ""
    $selection = Read-Host "Selecciona el número de la app que quieres instalar"
    return [int]$selection
}

function Install-App($app) {
    $appFolder = if ($app.ContainsKey("SubFolder")) {
        Join-Path $installerPath $app.SubFolder
    } else {
        $installerPath
    }

    $fullPath = Join-Path $appFolder $app.File

    if (-not (Test-Path $fullPath)) {
        Write-Host "❌ Instalador no encontrado: $fullPath" -ForegroundColor Red
        return
    }

    Write-Host "🚀 Instalando $($app.Name)..."
    Start-Process -FilePath $fullPath -ArgumentList $app.Args -WorkingDirectory $appFolder -Wait
    Write-Host "✅ $($app.Name) instalado.`n"
}

do {
    $choice = Show-Menu

    if ($apps.ContainsKey($choice)) {
        $app = $apps[$choice]

        if ($app.Special) {
            foreach ($k in $apps.Keys) {
                if (-not $apps[$k].Special) {
                    Install-App $apps[$k]
                }
            }
        } else {
            Install-App $app
        }

        Write-Host "`n¿Deseas instalar otra aplicación?" -ForegroundColor Yellow
        $again = Read-Host "Escribe 's' para volver al menú o cualquier otra tecla para salir"
    } else {
        Write-Host "Opción inválida." -ForegroundColor Red
        $again = "s"
    }

} while ($again -eq "s")