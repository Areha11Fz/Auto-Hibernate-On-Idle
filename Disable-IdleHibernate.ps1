$taskName = "Force Hibernate After Idle (Cancelable)"

schtasks /delete /tn "$taskName" /f 2>$null | Out-Null

Write-Host "Idle hibernate task DISABLED."
