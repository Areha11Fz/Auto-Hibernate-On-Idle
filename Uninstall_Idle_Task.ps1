$TaskName = "ForceHibernateIdleMonitor"

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Run as Administrator."
    Exit
}

Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false
Write-Host "Task Removed." -ForegroundColor Green

# Kill running process
Get-WmiObject Win32_Process | Where-Object { $_.CommandLine -like "*ForceIdle.ps1*" } | Stop-Process -Force