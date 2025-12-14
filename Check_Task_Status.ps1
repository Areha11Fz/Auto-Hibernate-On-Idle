$TaskName = "ForceHibernateIdleMonitor"

Write-Host "Checking Task Scheduler for: $TaskName" -ForegroundColor Cyan
Write-Host "----------------------------------------"

# Try to get the task
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if ($task) {
    Write-Host "STATUS: FOUND (The Task is still installed)" -ForegroundColor Red
    Write-Host "State:  $($task.State)"
    Write-Host "Path:   $($task.TaskPath)"
    Write-Host "Author: $($task.Author)"
}
else {
    Write-Host "STATUS: NOT FOUND (The Task is definitely uninstalled)" -ForegroundColor Green
}

Write-Host "`nChecking for running Background Script..."
# Check if the actual script is running in memory
$runningProcess = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*ForceIdle.ps1*" }

if ($runningProcess) {
    Write-Host "WARNING: The script is still running in memory (Process ID: $($runningProcess.ProcessId))" -ForegroundColor Yellow
} else {
    Write-Host "Clean. No background script running." -ForegroundColor Green
}

Write-Host "----------------------------------------"
Pause