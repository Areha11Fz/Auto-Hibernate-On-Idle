# --- CONFIGURATION ---
$TaskName   = "ForceHibernateIdleMonitor"
$ScriptName = "ForceIdle.ps1"

# --- GET CURRENT DIRECTORY ---
# This finds the directory where this script is currently running
$CurrentDir = $PSScriptRoot
$ScriptPath = Join-Path -Path $CurrentDir -ChildPath $ScriptName

# --- CHECK ADMIN ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please right-click and select 'Run as Administrator'."
    Start-Sleep -Seconds 5
    Exit
}

# --- VALIDATE FILE EXISTS ---
if (-not (Test-Path $ScriptPath)) {
    Write-Error "Could not find '$ScriptName' in this folder."
    Write-Host "Expected path: $ScriptPath" -ForegroundColor Red
    Write-Host "Please make sure both scripts are in the same folder." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Exit
}

# --- CLEANUP OLD TASK ---
$taskExists = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($taskExists) {
    Write-Host "Removing old task version..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# --- CREATE NEW TASK ---
Write-Host "Installing task linked to: $ScriptPath" -ForegroundColor Cyan

# Note: We wrap $ScriptPath in escaped quotes (`") to handle spaces in folder names
$ArgString = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`""

$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $ArgString
$Trigger = New-ScheduledTaskTrigger -AtLogOn
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Days 0) -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description "Force Hibernate (Path: $ScriptPath)" | Out-Null

Write-Host "SUCCESS! Task installed." -ForegroundColor Green
$ans = Read-Host "Start the idle monitor now? (Y/N)"
if ($ans -eq "Y") { Start-ScheduledTask -TaskName $TaskName }