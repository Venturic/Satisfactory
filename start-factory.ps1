[CmdletBinding()]
param (
    [Parameter(Position=0)]
    [switch]$Start,
    [switch]$Status,
    [switch]$Stop,
    [switch]$updateServer
)

$logfile = "C:\gameservers\satisfactoryserver\logs\myupdate-$(Get-Date -F yyyyMMdd-HHmm).log"

function Start-Server{    
    Write-Verbose "Démarrage du serveur"
    Start-Process -FilePath "C:\gameservers\satisfactoryserver\FactoryServer.exe" -ArgumentList "-log LOG=console.log -unattended"
    Write-Verbose "Console.log dans C:\gameservers\satisfactoryserver\FactoryGame\Saved\Logs"
    }
function Stop-Server{
    Write-Verbose "Arrêt du serveur"
    Get-Process -Name "FactoryServer" | Stop-Process -Force -ErrorAction SilentlyContinue
    Get-Process -Name "UE4Server-Win64-Shipping" | Stop-Process -Force -ErrorAction SilentlyContinue
}
function Get-ServerStatus{    
    $ProcessActive = Get-Process -ProcessName "FactoryServer" -ErrorAction SilentlyContinue
    if($null -eq $ProcessActive) {
        Write-Warning "Aucun exécutable trouvé !"
        exit 1
    } else {
        Write-Information "L'exécutbale est déjà démarré !"
        write-host "###### Executable informations" -ForegroundColor DarkCyan
        Get-Process -ProcessName "FactoryServer"
        write-host "###### UDP Ports informations" -ForegroundColor DarkCyan
        Get-NetUDPEndPoint | Select-Object LocalAddress, LocalPort, @{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}} | Sort-Object -Property LocalPort,Process | Where-Object{$_.Process -like "UE4Server-Win64-Shipping"}

    }
}
function Start-UpdateServer{
    Write-Verbose "Arrêt du serveur"
    try {
    Get-Process -Name "FactoryServer" | Stop-Process -Force
    Get-Process -Name "UE4Server-Win64-Shipping" | Stop-Process -Force
    } catch {
    Write-Warning "Echec de l'arret du processus, vérifier avec -status si il a encore des processus qui tournes"
    exit 1
    }
    Start-Process -FilePath "C:\Outils\Steam\steamcmd.exe" -ArgumentList "+force_install_dir C:\GameServers\SatisfactoryServer +login anonymous +app_update 1690800 -beta experimental validate +quit" -Wait -RedirectStandardOutput $logfile
}

if ($updateServer.IsPresent) {
    Stop-Server
        Start-Sleep -Seconds 3
    Start-UpdateServer
        Start-Sleep -Seconds 3
    Start-Server
        Write-Host "Attendre un peu lors du démarrage du serveur"
        Start-Sleep -Seconds 10
    Get-ServerStatus
    exit
}

if ($Start.IsPresent) {
    Start-Server
}
if ($Status.IsPresent) {
    Get-ServerStatus
}
if ($Stop.IsPresent) {
    Stop-Server
}