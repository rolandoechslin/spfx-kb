<#
.SYNOPSIS

Services status check for multiple computers

.DESCRIPTION

This powershell script is used to retrive the services status of mutliple servers.

.NOTES

Here are some cool important stuffs to note before executing the script

File Name: ServicesStatus.PS1
    
Author: Ramabadran Vasudevan| E-mail: rambadran@hotmail.com 

Source: https://gallery.technet.microsoft.com/Status-Check-2821d7bd

Follow me on

LinkedIn: https://in.linkedin.com/in/ramabadran

Microsoft: https://social.msdn.microsoft.com/profile/ramabadran%20vasudevan/
    
Prerequisites: 

1.	Windows 7 Operating system or Windows server 2008 Operating system.
2.	PowerShell V3 and later versions.
3.	Set the execution policy of system to unrestricted.

Copyright 2019 - Ramabadran Vasudevan.


.LINK -N/A
  

.EXAMPLE 1

.\ServicesStatus.ps1 - Directly run the script by right clicking and run script.
Refer the documentation in portal for how to execute it.

.EXAMPLE 2

To check the status of specific service you can use filter option
.\ServicesStatus.ps1 -Filter "Name='BITS'"

#>

$ServerArray= Get-Content "c:\Admin\Servers.txt"
$DefineSaveLocation=""
if ($DefineSaveLocation -eq "")
    {$DefineSaveLocation="C:\Admin\"}
$SavetoLocaPath = Test-Path $DefineSaveLocation
if ($SavetoLocaPath -eq $False)
    {New-Item -ItemType directory -Path $DefineSaveLocation}
cd $DefineSaveLocation
Foreach ($Server in $ServerArray )
 {
  Write-Host "Retrieving Servers for $Server "  
   Get-WmiObject win32_service -ComputerName $ServerArray | select Name,@{N="Startup Type";E={$_.StartMode}},@{N="Service Account";E={$_.StartName}},
  @{N="System Name";E={$_.Systemname}} | Sort-Object "Name" > ".\$Server -Services.txt"
 }
 Invoke-Item "$DefineSaveLocation"