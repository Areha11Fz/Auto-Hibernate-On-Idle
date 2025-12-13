$taskName = "Force Hibernate After Idle (Cancelable)"

# Ensure hibernate is enabled
powercfg /hibernate on | Out-Null

# Remove existing task if it exists
schtasks /delete /tn "$taskName" /f 2>$null | Out-Null

# Create the scheduled task
schtasks /create `
  /tn "$taskName" `
  /sc ONIDLE `
  /ru SYSTEM `
  /rl HIGHEST `
  /tr "shutdown.exe /h /f /t 60 /c `"System will hibernate in 60 seconds due to inactivity. Close this window to cancel.`""

Write-Host "Idle hibernate task ENABLED with 60-second cancelable popup."
