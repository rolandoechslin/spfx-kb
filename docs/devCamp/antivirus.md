# Antivirus

## Uninstall Trend Micro

- Neustart in Safe-Mode [Support Lenovo](https://pcsupport.lenovo.com/ch/de/products/laptops-and-netbooks/thinkpad-13-series-laptop/thinkpad-13-type-20j1-20j2/solutions/ht116905)
- regedit
- HKEY_LOCAL_MACHINE\SOFTWARE\TrendMicro\PC-cillinNTCorp\CurrentVersion\Misc
- Allow Uninstall from 0 to 1
- Deinstallieren

## Add defender exclusions

```bs
Add-MpPreference -ExclusionPath "C:\Temp"
```

```bs
Add-MpPreference -ExclusionPath "C:\Projects"
```
