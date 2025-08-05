function Run-AsAdmin {
    param($file, $args)
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $file
    $psi.Arguments = $args
    $psi.Verb = "runas"
    $psi.UseShellExecute = $true
    [System.Diagnostics.Process]::Start($psi) | Out-Null
}

$apps = @{
    1 = @{ Name = "Office"; Url = "https://1drv.ms/u/.../setup.exe?download=1"; Args = "" }
    2 = @{ Name = "Google Chrome"; Url = "https://1drv.ms/u/.../chrome.exe?download=1"; Args = "" }
    3 = @{ Name = "WinRAR"; Url = "https://1drv.ms/u/.../winrar.exe?download=1"; Args = "" }
    4 = @{ Name = "Instalar TODOS"; Special = $true }
    0 = @{ Name = "Salir"; Exit = $true }
}

function Show-Menu {
    Clear-Host
    Write-Host "===============================" -ForegroundColor Gray
    Write-Host "[JXJ17X Scripting]" -ForegroundColor Red
    Write-Host "===============================" -ForegroundColor Gray
    Write-Host "===== Instalador desde OneDrive =====" -ForegroundColor Cyan
    foreach ($k in ($apps.Keys | Sort-Object)) {
        Write-Host "$k. $($apps[$k].Name)"
    }
    $sel = Read-Host "Selecciona una opción"
    return [int]$sel
}

function Install-App($app) {
    $temp = Join-Path $env:TEMP "$($app.Name)_$(Get-Random).exe"
    Write-Host "🌐 Descargando $($app.Name)..."
    try {
        Invoke-WebRequest -Uri $app.Url -OutFile $temp
    } catch {
        Write-Host "❌ Error al descargar $($app.Name)" -ForegroundColor Red
        return
    }
    Write-Host "🔒 Ejecutando instalador como administrador..."
    try {
        Run-AsAdmin -file $temp -args $app.Args
        Write-Host "✅ Instalador iniciado. Completa la instalación manualmente." -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al ejecutar $($app.Name)" -ForegroundColor Red
    }
}

do {
    $choice = Show-Menu
    if ($apps.ContainsKey($choice)) {
        $app = $apps[$choice]
        if ($app.ContainsKey("Exit") -and $app.Exit) {
            Write-Host "👋 Cerrando script..." -ForegroundColor DarkGray
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
        $again = Read-Host "Pulsa 's' para volver al menú o cualquier otra tecla para salir"
    } else {
        Write-Host "❌ Opción inválida." -ForegroundColor Red
        $again = "s"
    }
} while ($again -eq "s")
