# --- CONFIGURATION ---
$IdleLimitSeconds = 1800   # 30 Minutes
$WarningSeconds   = 60    # Countdown popup duration

# --- NATIVE WINDOWS API SETUP ---
Add-Type @'
    using System;
    using System.Runtime.InteropServices;
    public class Win32 {
        [DllImport("user32.dll")]
        public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }
'@

function Get-RawIdleTime {
    $lii = New-Object LASTINPUTINFO
    $lii.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($lii)
    if ([Win32]::GetLastInputInfo([ref]$lii)) {
        $uptime = [Environment]::TickCount
        # Handle TickCount wrapping
        if ($uptime -lt $lii.dwTime) {
            return [Math]::Floor(([Int32]::MaxValue - $lii.dwTime + $uptime) / 1000)
        }
        return [Math]::Floor(($uptime - $lii.dwTime) / 1000)
    }
    return 0
}

# --- INITIALIZATION ---
$host.ui.RawUI.WindowTitle = "Idle Monitor"
$LastLoopTime = Get-Date
$IdleOffset = 0  # Used to "zero out" time after waking up

while ($true) {
    $CurrentTime = Get-Date
    
    # 1. DETECT WAKE UP (Time Gap Check)
    # If the script paused for > 10 seconds, the system likely slept/hibernated.
    $TimeGap = ($CurrentTime - $LastLoopTime).TotalSeconds
    
    $RawIdle = Get-RawIdleTime
    
    if ($TimeGap -gt 10) {
        # We just woke up!
        # The RawIdle will be huge (e.g. 30 mins from before sleep).
        # We set an offset to ignore that previous time.
        $IdleOffset = $RawIdle
    }
    
    # 2. CALCULATE ADJUSTED IDLE
    # Effective Idle = The API Idle Time minus the "Wake Up Offset"
    $AdjustedIdle = $RawIdle - $IdleOffset
    
    # 3. RESET OFFSET IF MOUSE MOVED
    # If the user moved the mouse, RawIdle drops to 0. 
    # This makes $AdjustedIdle negative (0 - 300 = -300). 
    # If negative, we know we can clear the offset.
    if ($AdjustedIdle -lt 0) {
        $IdleOffset = 0
        $AdjustedIdle = 0
    }

    # 4. CHECK LIMITS
    if ($AdjustedIdle -ge $IdleLimitSeconds) {
        $wshell = New-Object -ComObject Wscript.Shell
        
        # Show Popup
        $result = $wshell.Popup("No mouse activity for $IdleLimitSeconds seconds.`n`nComputer will hibernate in $WarningSeconds seconds.`n`nClick OK to Cancel.", $WarningSeconds, "Idle Hibernate Warning", 48)

        if ($result -eq 1) {
            # User clicked OK (Cancel)
            # Reset offset to current Raw so we don't trigger again immediately
            $IdleOffset = Get-RawIdleTime
            Start-Sleep -Seconds 5
        } 
        elseif ($result -eq -1) {
            # Timeout -> Hibernate
            rundll32.exe powrprof.dll,SetSuspendState 0,1,0
            
            # Wait after hibernate command to prevent instant re-trigger on wake
            Start-Sleep -Seconds 15
            
            # When we wake up here, ensure we reset logic immediately
            $IdleOffset = Get-RawIdleTime
            $LastLoopTime = Get-Date
        }
    }
    
    $LastLoopTime = $CurrentTime
    Start-Sleep -Seconds 2
}