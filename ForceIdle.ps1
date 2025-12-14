# CONFIGURATION
$IdleLimitSeconds = 300   # 5 Minutes
$WarningSeconds   = 60    # Countdown popup

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

function Get-UserIdleTime {
    $lii = New-Object LASTINPUTINFO
    $lii.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($lii)
    if ([Win32]::GetLastInputInfo([ref]$lii)) {
        $uptime = [Environment]::TickCount
        if ($uptime -lt $lii.dwTime) {
            return [Math]::Floor(([Int32]::MaxValue - $lii.dwTime + $uptime) / 1000)
        }
        return [Math]::Floor(($uptime - $lii.dwTime) / 1000)
    }
    return 0
}

$host.ui.RawUI.WindowTitle = "Idle Monitor"

while ($true) {
    $currentIdle = Get-UserIdleTime
    if ($currentIdle -ge $IdleLimitSeconds) {
        $wshell = New-Object -ComObject Wscript.Shell
        $result = $wshell.Popup("No mouse activity for $IdleLimitSeconds seconds.`n`nComputer will hibernate in $WarningSeconds seconds.`n`nClick OK to Cancel.", $WarningSeconds, "Idle Hibernate Warning", 48)

        if ($result -eq 1) {
            Start-Sleep -Seconds 5
        } 
        elseif ($result -eq -1) {
            rundll32.exe powrprof.dll,SetSuspendState 0,1,0
            Start-Sleep -Seconds 10
        }
    }
    Start-Sleep -Seconds 2
}