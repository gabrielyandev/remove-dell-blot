#Requires -RunAsAdministrator

# permitir execução temporária de scripts
Set-ExecutionPolicy Bypass -Scope Process

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdmin {
    $id  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $pri = New-Object Security.Principal.WindowsPrincipal $id
    return $pri.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Host "Desenvolvido por Gabriel Yan - gabrielyandev.com.br" -ForegroundColor Green
    Write-Warning "Este script deve ser executado como Administrador para desinstalações confiaveis."
}

function Get-UninstallEntries {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$DisplayNamePattern  # aceita caracteres curinga; use string exata se desejar
    )

    $roots = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
    )

    $entries = foreach ($root in $roots) {
        if (Test-Path $root) {
            Get-ChildItem -Path $root -ErrorAction SilentlyContinue |
            Get-ItemProperty -ErrorAction SilentlyContinue |
            Where-Object { 
                # Verificar se as propriedades existem antes de acessá-las
                $hasDisplayName = [bool]($_.PSObject.Properties.Name -contains 'DisplayName')
                $hasUninstallString = [bool]($_.PSObject.Properties.Name -contains 'UninstallString')
                
                if ($hasDisplayName -and $hasUninstallString) {
                    $_.DisplayName -and $_.UninstallString -and $_.DisplayName -like $DisplayNamePattern
                } else {
                    $false
                }
            }
        }
    }

    # Remover duplicatas baseado no caminho da chave se o mesmo item for visto duas vezes
    $entries | Sort-Object PSPath -Unique
}

function Invoke-Uninstall {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$AppName,             # aceita caracteres curinga
        [ValidateSet('Auto','MSI','EXE')][string]$Type='Auto',
        [string[]]$ExeSilentArgs = @('/S','/silent','-silent','/verysilent','/quiet'),
        [switch]$NoRestart
    )

    $matches = Get-UninstallEntries -DisplayNamePattern $AppName
    if (-not $matches) {
        Write-Host "$AppName nao esta instalado neste computador" -ForegroundColor Yellow
        return
    }

    foreach ($m in $matches) {
        $un = $m.UninstallString
        $displayName = $m.DisplayName
        
        # Verificar se WindowsInstaller existe antes de acessar
        $hasWindowsInstaller = [bool]($m.PSObject.Properties.Name -contains 'WindowsInstaller')
        $isMsi = ($hasWindowsInstaller -and $m.WindowsInstaller -eq 1) -or ($un -match '(?i)^\s*msiexec(\.exe)?\b')

        if ($Type -eq 'MSI' -or ($Type -eq 'Auto' -and $isMsi)) {
            # Normalizar para msiexec /X {GUID} /qn
            $guid = if ($m.PSChildName -match '^\{[0-9A-F-]{36}\}$') { $m.PSChildName } else { $null }
            if ($un -match '(?i)\s/I') { $un = ($un -replace '(?i)\s/I',' /X') }
            elseif ($guid) { $un = "msiexec.exe /x $guid" }

            if ($NoRestart) {
                $un += ' /qn /norestart'
            } else {
                $un += ' /qn'
            }
            
            if ($PSCmdlet.ShouldProcess($displayName, "Desinstalar (MSI)")) {
                Write-Host "Desinstalando: $displayName" -ForegroundColor Green
                Start-Process -FilePath 'cmd.exe' -ArgumentList "/c $un" -Wait -NoNewWindow
            }
        }
        else {
            # EXE: separar caminho e argumentos, preservar argumentos existentes, adicionar flag silenciosa se não presente
            $exe, $args = if ($un -match '^\s*"([^"]+)"\s*(.*)$') {
                $matches[1], $matches[2]
            } else {
                ($un -split '\s+', 2) + @('') | Select-Object -First 2
            }

            # Adicionar o primeiro argumento silencioso que não está presente
            $silentToAdd = ($ExeSilentArgs | Where-Object { $args -notmatch [regex]::Escape($_) } | Select-Object -First 1)
            $finalArgs = ($args, $silentToAdd) -join ' '

            if ($PSCmdlet.ShouldProcess($displayName, "Desinstalar (EXE): $exe $finalArgs")) {
                Write-Host "Desinstalando: $displayName" -ForegroundColor Green
                Start-Process -FilePath $exe -ArgumentList $finalArgs -Wait -NoNewWindow
            }
        }
    }
}

function Remove-AppxPackageEverywhere {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][string]$AppName)

    Write-Host "Procurando Appx: $AppName" -ForegroundColor Cyan
    $apps = Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq $AppName -or $_.PackageFamilyName -eq $AppName }
    if (-not $apps) { 
        Write-Host "$AppName nao esta instalado neste computador" -ForegroundColor Yellow
        return
    }
    
    foreach ($p in $apps) {
        if ($PSCmdlet.ShouldProcess($p.Name, "Remover Appx para todos os usuarios")) {
            Write-Host "Removendo Appx: $($p.Name)" -ForegroundColor Green
            Remove-AppxPackage -Package $p.PackageFullName -AllUsers -ErrorAction SilentlyContinue
        }
    }

    $prov = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $AppName -or $_.PackageName -like "*$AppName*" }
    foreach ($pp in $prov) {
        if ($PSCmdlet.ShouldProcess($pp.DisplayName, "Desprovisionar")) {
            Write-Host "Desprovisionando: $($pp.DisplayName)" -ForegroundColor Green
            Remove-AppxProvisionedPackage -Online -PackageName $pp.PackageName | Out-Null
        }
    }
}

function Show-UninstallString {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$AppName)
    $matches = Get-UninstallEntries -DisplayNamePattern $AppName
    if ($matches) { 
        Write-Host "Entradas de desinstalacao encontradas para '$AppName':" -ForegroundColor Cyan
        $matches | Select-Object DisplayName, UninstallString | Format-Table -AutoSize 
    }
    else { 
        Write-Host "$AppName nao esta instalado neste computador" -ForegroundColor Yellow 
    }
}

# ---------------------------
# Execução principal
# ---------------------------

Write-Host "Iniciando remocao de aplicativos Dell e Windows desnecessarios..." -ForegroundColor Yellow
Write-Host "Execute com -WhatIf primeiro para testar!" -ForegroundColor Magenta
Write-Host ""

# Perguntar se o usuario quer fazer um teste primeiro
$testFirst = Read-Host "Deseja executar em modo de teste (WhatIf) primeiro? (S/N)"
$whatIfParam = @{}
if ($testFirst -eq 'S' -or $testFirst -eq 's') {
    $whatIfParam.WhatIf = $true
    Write-Host "`n=== MODO DE TESTE - Nada sera realmente desinstalado ===" -ForegroundColor Magenta
} else {
    Write-Host "`n=== MODO DE EXECUCAO - Aplicativos serao desinstalados ===" -ForegroundColor Red
    $confirm = Read-Host "Tem certeza que deseja continuar? (S/N)"
    if ($confirm -ne 'S' -and $confirm -ne 's') {
        Write-Host "Operacao cancelada pelo usuario." -ForegroundColor Yellow
        exit
    }
}

Write-Host "`n=== REMOVENDO APLICATIVOS DELL ===" -ForegroundColor Yellow

Invoke-Uninstall -AppName 'Dell SupportAssist' -NoRestart @whatIfParam
Invoke-Uninstall -AppName 'Dell Digital Delivery Services' -NoRestart @whatIfParam
Invoke-Uninstall -AppName 'Dell Optimizer Core' @whatIfParam
Invoke-Uninstall -AppName 'Dell SupportAssist OS Recovery Plugin for Dell Update' @whatIfParam
Invoke-Uninstall -AppName 'Dell SupportAssist Remediation' @whatIfParam
Invoke-Uninstall -AppName 'Dell Display Manager 2.1' @whatIfParam
Invoke-Uninstall -AppName 'Dell Peripheral Manager' @whatIfParam
Invoke-Uninstall -AppName 'Dell Core Services' -NoRestart @whatIfParam
Invoke-Uninstall -AppName 'Dell Trusted Device Agent' -NoRestart @whatIfParam
Invoke-Uninstall -AppName 'Dell Optimizer' -NoRestart @whatIfParam

Write-Host "`n=== REMOVENDO APLICATIVOS WINDOWS DESNECESSARIOS ===" -ForegroundColor Yellow

Remove-AppxPackageEverywhere 'Microsoft.GamingApp' @whatIfParam
Remove-AppxPackageEverywhere 'Microsoft.MicrosoftOfficeHub' @whatIfParam
Remove-AppxPackageEverywhere 'DellInc.DellDigitalDelivery' @whatIfParam
Remove-AppxPackageEverywhere 'Microsoft.GetHelp' @whatIfParam
Remove-AppxPackageEverywhere 'Microsoft.Getstarted' @whatIfParam
Remove-AppxPackageEverywhere 'Microsoft.Messaging' @whatIfParam
Remove-AppxPackageEverywhere 'Microsoft.MicrosoftSolitaireCollection' @whatIfParam
Remove-AppxPackageEverywhere 'Microsoft.OneConnect' @whatIfParam
Remove-AppxPackageEverywhere 'Microsoft.SkypeApp' @whatIfParam
Remove-AppxPackageEverywhere 'Microsoft.Wallet' @whatIfParam
Remove-AppxPackageEverywhere 'microsoft.windowscommunicationsapps' @whatIfParam
Remove-AppxPackageEverywhere 'Microsoft.WindowsFeedbackHub' @whatIfParam
Remove-AppxPackageEverywhere 'Microsoft.YourPhone' @whatIfParam
Remove-AppxPackageEverywhere 'ZuneMusic' @whatIfParam

Write-Host "`n=== VERIFICANDO ENTRADAS DELLOSD ===" -ForegroundColor Yellow
Show-UninstallString 'DELLOSD'

Write-Host "`nProcesso concluido!" -ForegroundColor Green
if ($whatIfParam.WhatIf) {
    Write-Host "Este foi um teste. Execute o script novamente e escolha 'N' para realmente desinstalar os aplicativos." -ForegroundColor Magenta
}