# Auto-Hibernate-On-Idle

A PowerShell-based system monitoring solution that automatically hibernates your Windows computer after detecting user inactivity for a specified duration.

## Overview

This project provides three PowerShell scripts that work together to monitor system idle time and trigger hibernation when your computer hasn't detected any user input (mouse/keyboard) for a configurable period. The monitoring task runs automatically at system logon using Windows Task Scheduler.

## Scripts

### 1. ForceIdle.ps1

**The Core Idle Monitor**

This is the main monitoring script that runs continuously and checks for user inactivity.

**Features:**

- Monitors user input activity in real-time using Windows API calls
- Configurable idle timeout (default: 5 minutes)
- Shows a warning popup before hibernating
- Provides a countdown timer and cancel option
- Automatically hibernates the system if the warning is not dismissed

**Configuration:**

```powershell
$IdleLimitSeconds = 300   # Idle time before hibernation (in seconds)
$WarningSeconds   = 60    # Warning popup countdown (in seconds)
```

**How it works:**

1. Continuously monitors time since last user input (mouse/keyboard activity)
2. When idle time reaches the limit, displays a warning popup
3. If user clicks "OK" or the timer expires, the system hibernates
4. Clicking "Cancel" in the popup prevents hibernation

---

### 2. Install_Idle_Task.ps1

**The Installation Script**

This script sets up the idle monitor to run automatically at system startup.

**What it does:**

- Requires Administrator privileges
- Validates that ForceIdle.ps1 exists in the same folder
- Removes any previous version of the scheduled task
- Creates a new Windows Scheduled Task named "ForceHibernateIdleMonitor"
- Configures the task to run at user logon
- Optionally starts the monitor immediately

**Requirements:**

- Must run as Administrator
- ForceIdle.ps1 must be in the same directory
- Both scripts must be in the same folder for the task to work correctly

---

### 3. Uninstall_Idle_Task.ps1

**The Uninstallation Script**

This script cleanly removes the idle monitoring system from your computer.

**What it does:**

- Requires Administrator privileges
- Unregisters the scheduled task "ForceHibernateIdleMonitor"
- Terminates any running ForceIdle.ps1 processes
- Cleans up all related system resources

---

## Installation

### Prerequisites

- Windows operating system with Task Scheduler
- Administrator privileges
- PowerShell 5.0 or higher

### Steps

1. **Download/Clone** this repository to a folder on your computer
2. **Open PowerShell as Administrator**
3. **Navigate** to the folder containing these scripts
4. **Run the installation script:**
   ```powershell
   .\Install_Idle_Task.ps1
   ```
5. **When prompted**, choose whether to start the monitor immediately

The idle monitor will now automatically start every time you log in.

---

## Uninstallation

### Steps

1. **Open PowerShell as Administrator**
2. **Navigate** to the folder containing these scripts
3. **Run the uninstallation script:**
   ```powershell
   .\Uninstall_Idle_Task.ps1
   ```

The idle monitor will be removed from your system and will no longer run at startup.

---

## Configuration

To change the idle timeout or warning duration, edit **ForceIdle.ps1** and modify these variables:

```powershell
$IdleLimitSeconds = 300   # Change this to desired seconds (e.g., 600 = 10 minutes)
$WarningSeconds   = 60    # Change this to desired countdown seconds
```

After making changes, reinstall the task by running:

```powershell
.\Install_Idle_Task.ps1
```

---

## How It Works

### Idle Detection

- Uses Windows API (`GetLastInputInfo`) to detect mouse and keyboard activity
- Calculates the time elapsed since the last user input
- Accounts for system uptime counter overflow

### Scheduled Task Configuration

- Task runs at logon with administrator privileges
- PowerShell executes in hidden mode (no visible window)
- Runs on battery power (won't stop if on battery)
- Uses `ExecutionPolicy Bypass` to avoid script execution restrictions

### Hibernation

- Uses `rundll32.exe powrprof.dll,SetSuspendState` to trigger hibernation
- User can cancel hibernation via the warning dialog
- 5-second grace period provided after cancellation

---

## Troubleshooting

### The script won't install

- Make sure you're running PowerShell **as Administrator**
- Verify both scripts are in the same folder
- Check that ForceIdle.ps1 is named exactly "ForceIdle.ps1"

### The monitor doesn't start at logon

- Verify the task exists in Task Scheduler: `Get-ScheduledTask -TaskName "ForceHibernateIdleMonitor"`
- Check if the task is enabled
- Review the task's "Last Run Result" in Task Scheduler for errors

### Hibernation not working

- Verify hibernation is enabled on your system
- Check if your system supports hibernation
- Try running `powercfg /h on` in Command Prompt (as Administrator)

### Manual Task Management

```powershell
# View the scheduled task
Get-ScheduledTask -TaskName "ForceHibernateIdleMonitor"

# Manually start the monitor
Start-ScheduledTask -TaskName "ForceHibernateIdleMonitor"

# Stop the running monitor
Stop-ScheduledTask -TaskName "ForceHibernateIdleMonitor"

# View task history
Get-ScheduledTaskInfo -TaskName "ForceHibernateIdleMonitor"
```

---

## Technical Details

### Architecture

- **Parent Process**: Windows Task Scheduler
- **Executable**: powershell.exe
- **Script**: ForceIdle.ps1
- **Execution Policy**: Bypass (for automated execution)
- **Window Mode**: Hidden

### API Usage

- `GetLastInputInfo()`: Retrieves the tick count of the last input event
- `SetSuspendState()`: Triggers system hibernation
- `Wscript.Shell.Popup()`: Displays interactive warning dialogs

### File Dependencies

```
Auto-Hibernate-On-Idle/
├── ForceIdle.ps1                   (Main monitoring script)
├── Install_Idle_Task.ps1           (Installation script)
├── Uninstall_Idle_Task.ps1         (Uninstallation script)
└── README.md                        (This file)
```

---

## License

This project is provided as-is for personal use.

---

## Support

For issues or questions:

1. Check the Troubleshooting section above
2. Review PowerShell error messages carefully
3. Ensure all scripts are in the same directory
4. Verify Administrator privileges are available
