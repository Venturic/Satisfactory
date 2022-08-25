<#
.SYNOPSIS
Get your Public IP

.DESCRIPTION
Automaticly get your Public IP, and simply show to you or send to your discord server automaticly in case of change.
This web site are used by default "https://ipinfo.io/ip","http://ifconfig.me/ip","https://api.ipify.org/ because the output is an obect not a standard web page. 

.PARAMETER ShowMyIP
Show your Public IP on Terminal

.PARAMETER SendToDiscord
Send your Public IP on discord for your friends, on first try or if the IP changed. (For automatic update in discord channel)

.PARAMETER Clean
Remove tempory file with older IP. Doing nothing else. 

.INPUTS
None. You cannot pipe objects to GetmyPublicip.ps1.

.OUTPUTS
GetmyPublicip.ps1 generate minimal information output, but you cannot use this with pipe.

.NOTES
The first Example, if the script is launched without argument, the -ShowMyIP is used. 

.EXAMPLE
PS> .\GetmyPublicip.ps1

.EXAMPLE
PS> .\GetmyPublicip.ps1 -ShowMyIP -Verbose

.EXAMPLE
PS> .\GetmyPublicip.ps1 -SendToDiscord

.EXAMPLE
PS> .\GetmyPublicip.ps1 -Clean

#>

[CmdletBinding()]
param (
    [switch]$SendToDiscord,
    [switch]$ShowMyIP,
    [switch]$Clean
    )

################################################################
################################################################
################################################################
################################################################
# Customized with your variables
$Mydiscord = "https://discord.com/api/webhooks/1010305575676031016/TVcKPjaPH3qxtZt6N3cumfGB38Uw-4efDKcOXQNp60eCBfPJ7nFmeyCAG3GGoVXwpddo"
$allSites = ("https://ipinfo.io/ip","http://ifconfig.me/ip","https://api.ipify.org/") 
$File = "$env:USERPROFILE\mypublicip.txt"
[int]$ChgtIP = 0
[int]$IEXError = 0

if ($Clean.IsPresent) {
    if(Test-Path -Path $File -PathType Leaf) {
        try {
        Remove-Item $File -Force -ErrorAction SilentlyContinue
        } catch { Write-Error $_}
        exit
    } else { Write-Verbose "No file"+$File+" to remove!"
    exit
    }
}

if (Test-Path $File)
{ $olderip = Get-Content -Path $File 
    Write-Verbose "Get older IP in file : $olderip"
    Remove-Item $File -Force -ErrorAction SilentlyContinue
} else { 
    $FirstStart = $true 
    Write-Verbose "First Start !"
} 
foreach ($Site in $allSites) {
    Write-Verbose "Try on $Site"
    try {   
    $ifconfig = $(Invoke-WebRequest -uri $Site -UseBasicParsing)
    } catch {
        Write-Error "$_"
        $IEXError = $IEXError+1
        continue
    }
    $ip = $ifconfig.Content 
    $Status = $ifconfig.StatusCode 
    $Description = $ifconfig.StatusDescription
    Write-Verbose "Return : $Description|$Status"
    if ($ifconfig.StatusCode -eq "200" -and $ifconfig.StatusDescription -eq "OK") { 
        Write-Verbose "Verified Error code and Status on $Site = OK"        
    } else { 
        Write-Warning "Have you internet :) ?" 
        continue}
    if (![string]::IsNullOrEmpty($olderip)) {
        Write-Verbose "Older IP : $olderip"
        if ("$ip" -eq "$olderip") {
            Write-Verbose "Same IP $ip"
        } else { 
        Write-Warning "Not the same IP (New IP : $ip / Older IP : $olderip)"
        $IPchange = 1
        $ChgtIP = $ChgtIP+1
        }
        # $olderip = "$ip"
    } else {
        if ($FirstStart -eq $true) {$IPchange = 1}
        $olderip = "$ip"
        Write-Verbose "First founded $olderip" 
    }
}

if ($IEXError -ge 3) { 
    Write-Error "Error on multiple connexion verify your internet connexion" 
    exit 1
} 

# Take change for new IP, inthis case is the new IP as  seen x2 => it is OK
if ($ChgtIP -ge 2 ) { 
    $olderip = "$ip"
    $ChgtIPs = $ChgtIP.ToString() 
    Write-Verbose "Ack is $ChgtIPs - New older IP $olderip" 
} 

if ($ShowMyIP.IsPresent -or $IPchange -eq 1) 
{
    Remove-Item $File -Force -ErrorAction SilentlyContinue
    Write-Host "My Public IP : $olderip" 
    Add-Content -Path $File -Value "$olderip"
}

if ($SendToDiscord.IsPresent -and $IPchange -eq 1) # Avoid sending too many messages to discord if the ip has not changed
{
    $HookUrl = $Mydiscord
    $content = @"
Ma Box a changer d'IP !
Voici ma nouvelle IP : $olderip
"@ 
    $payload = [PSCustomObject]@{
        content = $content }
    Remove-Item $File -Force -ErrorAction SilentlyContinue
    Write-Host "Send IP to Discord..." 
    try {
    Invoke-RestMethod -Uri $HookUrl -Method Post -Body ($payload | ConvertTo-Json) -ContentType 'application/json'
    } catch {
    Write-Host "An error occured to send information to Discord" 
    Write-Error "$_"
    exit 1
    }
Add-Content -Path $File -Value "$olderip"
} 