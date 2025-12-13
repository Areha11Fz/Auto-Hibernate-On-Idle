$taskName = "Force Hibernate After Idle (Cancelable)"
$tempXml = "$env:TEMP\IdleHibernateTask.xml"

# Ensure hibernate is enabled
powercfg /hibernate on | Out-Null

# Delete existing task if present
schtasks /delete /tn "$taskName" /f 2>$null | Out-Null

# Create task XML
$xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <IdleTrigger>
      <Enabled>true</Enabled>
    </IdleTrigger>
  </Triggers>
  <Principals>
    <Principal id="System">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
  </Settings>
  <Actions Context="System">
    <Exec>
      <Command>shutdown.exe</Command>
      <Arguments>/h /f /t 60 /c "System will hibernate in 60 seconds due to inactivity. Close this window to cancel."</Arguments>
    </Exec>
  </Actions>
</Task>
"@

# Write XML to temp file
$xml | Out-File -Encoding Unicode $tempXml

# Create the task from XML
schtasks /create /tn "$taskName" /xml $tempXml /ru SYSTEM

# Cleanup
Remove-Item $tempXml -Force

Write-Host "Idle hibernate task ENABLED with 60-second cancelable popup."
