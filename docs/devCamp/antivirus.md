# Uninstall Trend Micro
* Neustart in Safe-Mode
* regedit
* HKEY_LOCAL_MACHINE\SOFTWARE\TrendMicro\PC-cillinNTCorp\CurrentVersion\Misc
* Allow Uninstall from 0 to 1
* Deinstallieren

# Add defender exclusions
Add-MpPreference -ExclusionPath "C:\Temp"
Add-MpPreference -ExclusionPath "C:\Projects"
Add-MpPreference -ExclusionPath "C:\Temp"