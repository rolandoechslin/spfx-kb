<#
=============================================================================================
Name:           Get Microsoft Teams and Their SharePoint Site URL Report
Version:        2.0
Website:        o365reports.com

Script Highlights: 
~~~~~~~~~~~~~~~~~
1.The script uses modern authentication to connect to Exchange Online.   
2.The script can be executed with MFA enabled account too.   
3.Exports report results to CSV. 
4.The script is scheduler friendly. I.e., You can pass the credential as parameters instead of saving inside the script.  

For detailed Script execution: https://o365reports.com/2021/07/13/export-office-365-user-manager-and-direct-reports-using-powershell
============================================================================================
#>
Param
(   [string]$Organization,
    [string]$ClientId,
    [string]$CertificateThumbprint,
    [string]$UserName,
    [string]$Password
)

Function Connect_Exo
{
 #Check for EXO module inatallation
 $Module = Get-Module ExchangeOnlineManagement -ListAvailable
 if($Module.count -eq 0) 
 { 
  Write-Host Exchange Online PowerShell module is not available  -ForegroundColor yellow  
  $Confirm= Read-Host Are you sure you want to install module? [Y] Yes [N] No 
  if($Confirm -match "[yY]") 
  { 
   Write-host "Installing Exchange Online PowerShell module"
   Install-Module ExchangeOnlineManagement -Repository PSGallery -AllowClobber -Force -Scope CurrentUser
   Import-Module ExchangeOnlineManagement
  } 
  else 
  { 
   Write-Host EXO module is required to connect Exchange Online.Please install module using Install-Module ExchangeOnlineManagement cmdlet. 
   Exit
  }
 } 
 Write-Host Connecting to Exchange Online...
 #Storing credential in script for scheduling purpose/ Passing credential as parameter - Authentication using non-MFA account
 if(($UserName -ne "") -and ($Password -ne ""))
 {
  $SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force
  $Credential  = New-Object System.Management.Automation.PSCredential $UserName,$SecuredPassword
  Connect-ExchangeOnline -Credential $Credential
 }
 elseif($Organization -ne "" -and $ClientId -ne "" -and $CertificateThumbprint -ne "")
 {
   Connect-ExchangeOnline -AppId $ClientId -CertificateThumbprint $CertificateThumbprint  -Organization $Organization -ShowBanner:$false
 }
 else
 {
  Connect-ExchangeOnline
 }
}

Connect_EXO

$OutputCSV="./TeamsSPOUrl_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"
$Result="" 
$Results=@() 
$ExportedCount=0

#Get Teams' site URL
#Get-UnifiedGroup “Filter {ResourceProvisioningOptions -eq "Team"} | Select DisplayName,SharePointSiteUrl,PrimarySMTPAddress,ManagedBy,AccessType,WhenCreated | Export-CSV $OutputCSV  -NoTypeInformation 
Get-UnifiedGroup -Filter {ResourceProvisioningOptions -eq "Team"} -ResultSize Unlimited | foreach {
 $ExportedCount++
 $DisplayName =$_.DisplayName
 Write-Progress -Activity "Exported Teams count: $ExportedCount" "Currently Processing Team: $DisplayName" 
 $SharePointSiteURL=$_.SharePointSiteURL
 $PrimarySMTPAddress=$_.PrimarySMTPAddress
 $Managers=$_.ManagedBy
 $AccessType=$_.AccessType
 $WhenCreated=$_.WhenCreated
 $ManagedBy= $Managers -join ","


 $Result = @{'Team Name'=$Displayname;'SharePoint Site URL'=$SharePointSiteURL;'Primary SMTP Address'=$PrimarySMTPAddress;'Managed By'=$ManagedBy;'Access type'=$AccessType;'Creation Time'=$WhenCreated} 
 $Results = New-Object PSObject -Property $Result 
 $Results |select-object 'Team Name','SharePoint Site URL','Primary SMTP Address','Managed By','Access type','Creation Time' | Export-CSV $OutputCSV  -NoTypeInformation -Append
}

#Open output file after execution
If($ExportedCount -eq 0)
{
 Write-Host No records found
}
else
{
 Write-Host `nThe output file contains $ExportedCount Teams and their site information
 if((Test-Path -Path $OutputCSV) -eq "True") 
 {
  Write-Host `n " The Output file availble in:" -NoNewline -ForegroundColor Yellow
  Write-Host $OutputCSV 
  Write-Host `n~~ Script prepared by AdminDroid Community ~~`n -ForegroundColor Green
  Write-Host "~~ Check out " -NoNewline -ForegroundColor Green; Write-Host "admindroid.com" -ForegroundColor Yellow -NoNewline; Write-Host " to get access to 1800+ Microsoft 365 reports. ~~" -ForegroundColor Green `n`n
  $Prompt = New-Object -ComObject wscript.shell   
  $UserInput = $Prompt.popup("Do you want to open output file?",`   
 0,"Open Output File",4)   
  If ($UserInput -eq 6)   
  {   
   Invoke-Item "$OutputCSV"   
  } 
 }
}

#Disconnect Exchange Online session
Disconnect-ExchangeOnline -Confirm:$false -InformationAction Ignore -ErrorAction SilentlyContinue