[CmdletBinding()]
param (
    [Parameter(Position=0)]
    [switch]$Start,
    [switch]$Status,
    [switch]$Stop
)

if ($Start.IsPresent) {
    Write-Verbose "Démarrage du serveur"
    Start-Process -FilePath "C:\gameservers\satisfactoryserver\FactoryServer.exe" -ArgumentList "-log -unattended"
    exit
}

if ($Status.IsPresent) {
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
        exit 
    }
}

if ($Stop.IsPresent) {
    Write-Verbose "Arrêt du serveur"
    try {
    Get-Process -Name "FactoryServer" | Stop-Process -Force
    Get-Process -Name "UE4Server-Win64-Shipping" | Stop-Process -Force
    } catch {
    Write-Warning "Echec de l'arret du processus, vérifier avec -status si il a encore des processus qui tournes"
    exit 1
    }
}