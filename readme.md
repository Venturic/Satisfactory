# Backup the backup files in a ZIP file on the Satisfactory dedicated server

Hello, This is my scrpit for satisfgactory dedicated server (for unreal engine)
Maybe working for you.

## DESCRIPTION
Simple scripts to backup anywhere Satifactory Backup ans start/stop/status :)
Any questions go to https://satisfactory.fandom.com/wiki/Dedicated_servers for answers.

### EXAMPLE
PS> .\BackupFactory.ps1 -Auto -Clean

### EXAMPLE
PS> .\BackupFactory.ps1 -SaveGamesPath $env:USERPROFILE\AppData\Local\FactoryGame\Saved\SaveGames\server -BackupPath F:\BackupFactory

### EXAMPLE
PS> .\BackupFactory.ps1 -CreateTask -Auto -Clean -Verbose

### EXAMPLE
PS> .\BackupFactory.ps1 -RemoveTask

### EXAMPLE
PS> .\BackupFactory.ps1 -Clean

### EXAMPLE
PS> .\start-factory.ps1 -start

### EXAMPLE
PS> .\start-factory.ps1 -status
###### Executable informations

 NPM(K)    PM(M)      WS(M)     CPU(s)      Id  SI ProcessName
 ------    -----      -----     ------      --  -- -----------
      7     1,17       4,84       0,00    9816   1 FactoryServer
###### UDP Ports informations

LocalAddress : ::
LocalPort    : 7777
Process      : UE4Server-Win64-Shipping


LocalAddress : ::
LocalPort    : 15000
Process      : UE4Server-Win64-Shipping


LocalAddress : 0.0.0.0
LocalPort    : 15777
Process      : UE4Server-Win64-Shipping


LocalAddress : ::
LocalPort    : 15777
Process      : UE4Server-Win64-Shipping

### EXAMPLE
PS> .\start-factory.ps1 -stop