# Auto-Hibernate-On-Idle

This repository contains PowerShell scripts to automatically manage Windows hibernation based on system idle time.

## Scripts

### Enable-IdleHibernate.ps1

Enables automatic hibernation when the system is idle for a specified period.

- Creates a scheduled task that triggers on system idle
- Forces hibernation after 60 seconds of inactivity
- Displays a cancelable popup notification (60 seconds) before hibernating
- Requires administrator privileges
- Ensures the hibernate feature is enabled on the system

### Disable-IdleHibernate.ps1

Disables the idle hibernation feature.

- Removes the scheduled task that was created by the Enable script
- No longer triggers hibernation on idle state

## Usage

### Prerequisites

Before running these scripts, set the execution policy to allow script execution:

```powershell
Set-ExecutionPolicy RemoteSigned
```

### Running the Scripts

Run PowerShell as Administrator, then execute the desired script:

```powershell
# Enable idle hibernation
.\Enable-IdleHibernate.ps1

# Disable idle hibernation
.\Disable-IdleHibernate.ps1
```

## Notes

- Both scripts require **Administrator privileges** to execute
- The scheduled task uses the SYSTEM account with HIGHEST privileges
- When hibernation is triggered, you have 60 seconds to cancel by closing the popup window
- Hibernation must be supported and enabled on your system for this to work
