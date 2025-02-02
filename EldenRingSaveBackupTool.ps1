#Change $backupDirectory to point to where you want to save your backups

$backupDirectory = "C:\Temp\EldenRingBackups"

#Change $numBackupsToKeep to alter how many backups to keep

$numBackupsToKeep = 5

#Change $delayMinutesBetweenBackups to alter how often backups are made

$delayMinutesBetweenBackups = 30

#Change $backupSeamlessCoop to alter whether backups are made of Seamless Coop Save Files

$backupSeamlessCoop = $true

#Change $backupVanilla to alter whether backups are made of Vanilla Elden Ring Save Files

$backupVanilla = $true

#Change if does crash or give errors about "$erSavePath = Join-Path -Path $erBasePath -ChildPath $userID"

$Multyple_Directory = $false
#After change the $Directory

#Change $Directory to select the only one you need, this mod actualy crash/dont work if you do have more the 1 directory at C:\Users\<...>\AppData\Roaming\EldenRing

$Directory = ""
# example $Directory = "76561198246504570"

#Don't change below code
###################################################################

$delaySeconds = $delayMinutesBetweenBackups * 60
$erBasePath = Join-Path -Path $env:APPDATA -ChildPath "\EldenRing"

if($Multyple_Directory){
	
	<# Force directory#>
	Write-Host "Forced directory selected."
	$userID = Get-ChildItem -Path $erBasePath -Name -Directory -Filter $Directory
	
}else {
	
	<# Auto directory#>
	Write-Host "Automatic directory selected."
	$userID = Get-ChildItem -Path $erBasePath -Name -Directory
	
}

$erSavePath = Join-Path -Path $erBasePath -ChildPath $userID
$deletePathSeamless = [IO.Path]::Combine($backupDirectory, '*\', '*.co2')
$deletePathVanilla = [IO.Path]::Combine($backupDirectory, '*\', '*.sl2')

while ($true){
    $date = Get-Date -Format yyyyMMddHHmm
    $currentBackupPath = Join-Path -Path $backupDirectory -ChildPath $date
    New-Item -ItemType Directory -Force -Path $currentBackupPath | Out-Null
    if ($backupSeamlessCoop)
    {
        robocopy $erSavePath $currentBackupPath *.co2 /NFL /NDL /NJH /NJS /nc /ns /np
    }

    if ($backupVanilla)
    {
        robocopy $erSavePath $currentBackupPath *.sl2 /NFL /NDL /NJH /NJS /nc /ns /np
    }
    
    Write-Host "Backed up save to " + $currentBackupPath
    Get-ChildItem -Path $deletePathSeamless | Sort-Object -Descending | Select-Object -Skip $numBackupsToKeep | Remove-Item
    Get-ChildItem -Path $deletePathVanilla | Sort-Object -Descending | Select-Object -Skip $numBackupsToKeep | Remove-Item

    do {
        $dirs = gci $backupDirectory -directory -recurse | Where { (gci $_.fullName -Force).count -eq 0 } | select -expandproperty FullName
        $dirs | Foreach-Object { Remove-Item $_ }
    } while ($dirs.count -gt 0)

    Write-Host "Hit Ctrl+C to close."
    Start-Sleep -Seconds $delaySeconds
}