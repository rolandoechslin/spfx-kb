#Connect to SharePoint admin center using an admin account
#Specify the URL to your SharePoint admin center site, e.g. https://contoso-admin.sharepoint.com

$url = 'https://contoso-admin.sharepoint.com'

#Specify a folder path to output the results into
$path = '.\'

#SMTP details
$Smtp = '<SmtpServer>'
$From = '<SenderEmailAddress>'  
$To = '<RecipientEmailAddress>'
$Subject = 'Site Storage Warning'  
$Body = 'Storage Usage Details'

if($url -eq '') {
    $url = Read-Host -Prompt 'Enter the SharePoint admin center URL'
}

Connect-SPOService -Url $url

#Local variable to create and store output file  
$filename = (Get-Date -Format o | foreach {$_ -Replace ":", ""})+'.csv'  
$fullpath = $path+$filename

#Enumerating all sites and calculating storage usage  
$sites = Get-SPOSite
$results = @()

foreach ($site in $sites) {
    $siteStorage = New-Object PSObject

    $percent = $site.StorageUsageCurrent / $site.StorageQuota * 100  
    $percentage = [math]::Round($percent,2)

    $siteStorage | Add-Member -MemberType NoteProperty -Name "Site Title" -Value $site.Title
    $siteStorage | Add-Member -MemberType NoteProperty -Name "Site Url" -Value $site.Url
    $siteStorage | Add-Member -MemberType NoteProperty -Name "Percentage Used" -Value $percentage
    $siteStorage | Add-Member -MemberType NoteProperty -Name "Storage Used (MB)" -Value $site.StorageUsageCurrent
    $siteStorage | Add-Member -MemberType NoteProperty -Name "Storage Quota (MB)" -Value $site.StorageQuota

    $results += $siteStorage
    $siteStorage = $null
}

$results | Export-Csv -Path $fullpath -NoTypeInformation

#Sending email with output file as attachment  
Send-MailMessage -SmtpServer $Smtp -To $To -From $From -Subject $Subject -Attachments $fullpath -Body $Body -Priority high