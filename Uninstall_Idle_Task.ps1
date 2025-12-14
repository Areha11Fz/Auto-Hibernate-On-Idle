$TaskName = "ForceHibernateIdleMonitor"

# 1. Remove the Scheduled Task
Write-Host "Removing Scheduled Task..." -ForegroundColor Cyan
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if ($task) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
    Write-Host "Task '$TaskName' successfully deleted." -ForegroundColor Green
} else {
    Write-Host "Task '$TaskName' was not found in Windows Scheduler." -ForegroundColor Yellow
}

# 2. Kill the Background Process (The Fixed Way)
Write-Host "Stopping background processes..." -ForegroundColor Cyan
$runningProcesses = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*ForceIdle.ps1*" }

if ($runningProcesses) {
    foreach ($proc in $runningProcesses) {
        Write-Host "Stopping Process ID: $($proc.ProcessId)" -ForegroundColor Yellow
        Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Background processes stopped." -ForegroundColor Green
} else {
    Write-Host "No background processes found." -ForegroundColor Green
}