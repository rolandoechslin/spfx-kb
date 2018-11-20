<#
	.SYNOPSIS
		Notify service health via e-mail

	.DESCRIPTION
        This script is intended to be setup as a scheduled task to utilize O365 RESTful API
        To query service health and send notifications via e-mail to those who need to be informed
        Additionally, you have the ability to scope the reporting to the services that are relevent
        to you team. Also, it includes scoping recipients to two separate audiences based on notification.

    .REQUIREMENTS
        Global administrator rights within Office 365 tenant
        Powershell version 5 or later for Nuget powershell gallery

    .AUTHOR
        Adam Devino
#>


#Required variable definition
#Path to store encrypted credentials
$pwdfilepath = ""
#Office 365 account username
$user = ""
#Path to save log files
$logfilepath = ""
#Email address to use as sender
$sender = ""
#Group of recipients for service degradation/restoration or outages notifications
$priorityRecipients= @()
#Group of recipients for general announcement service health notifications
$notificationRecipients = @()
#Ip address or DNS record used to point to SMTP relay server
$smtpserver = ""

#Services to recieve notifications on. Add/Remove services as needed.
$ReportServices =@(
"Exchange Online",
"SharePoint Online",
"Skype for Business",
"Office Subscription",
"Social Engagement",
"Power BI",
"Microsoft Teams",
"Yammer Enterprise",
"Yammer.com",
"OneDrive for Business",
"Identity Service",
"Planner",
"Sway",
"Office 365 Portal")

<#
"Exchange Online"
"SharePoint Online"
"Skype for Business"
"Office Subscription"
"Social Engagement"
"Power BI"
"Microsoft Teams"
"Yammer Enterprise"
"Yammer.com"
"OneDrive for Business"
"Identity Service"
"Planner"
"Sway"
"Office 365 Portal"
#>

#Creates password key if it does not exsist
if ((Test-Path "$pwdfilepath\pwdfile.txt") -eq $false)
{

    try 
    {

        if ((test-path $pwdfilepath) -eq $false)
        {

            New-Item -ItemType Directory -Path $pwdfilepath
        
        }

        Read-Host "Enter Password" -AsSecureString | ConvertFrom-SecureString | Out-File "$pwdfilepath\pwdfile.txt" -ErrorAction Stop

        $acl = Get-Acl "$pwdfilepath\pwdfile.txt"
        $permission = "BUILTIN\Users","Modify","Allow"
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
        $acl.SetAccessRule($accessRule)
        $acl | Set-Acl "$pwdfilepath\pwdfile.txt"

    }
    catch 
    {

        Write-Error "Unable to update permissions on $pwdfilepath\pwdfile.txt - Execute script as administrator for initial configuration"

    }

}

#Read password into session
$pwd = Get-Content "$pwdfilepath\pwdfile.txt" | Convertto-SecureString
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pwd

$O365Creds = (@{userName=$creds.username;password=$Creds.GetNetworkCredential().password;} | convertto-json).tostring()
try
{

    $Authtoken = (
        invoke-restmethod `
        -contenttype "application/json" `
        -method Post `
        -uri "https://api.admin.microsoftonline.com/shdtenantcommunications.svc/Register" `
        -body $O365Creds -ErrorAction Stop `
        ).RegistrationCookie

}
catch
{
    
    write-error $_

    if ($_.exception.message -eq "The remote server returned an error: (401) Unauthorized.")
    {

        Write-Output "Unable to authenticate with credentials provided - Password file has been reset"

        Remove-Item "$pwdfilepath\pwdfile.txt"
    
    }

    Exit

}
$Authsession = (@{
    lastCookie=$Authtoken;
    locale="en-US";
    preferredEventTypes=@(0,1)} | `
    convertto-json).tostring()

$events = (
    invoke-restmethod `
    -contenttype "application/json" `
    -method Post `
    -uri "https://api.admin.microsoftonline.com/shdtenantcommunications.svc/GetEvents" `
    -body $Authsession)

$events = (($events |? {$_.eventinfotype -eq 1}).events)

#File to store logs
$outputfile = "$logfilepath\ServiceHealth.txt"

If ((Test-Path $outputfile) -eq $false)
{

    try 
    {

        if ((Test-Path $logfilepath) -eq $false)
        {
    
            New-Item -ItemType Directory -Path $logfilepath -ErrorAction Stop
        
        }

        New-Item -ItemType File -Path $outputfile -ErrorAction Stop

        $acl = Get-Acl $outputfile
        $permission = "BUILTIN\Users","Modify","Allow"
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
        $acl.SetAccessRule($accessRule)
        $acl | Set-Acl $outputfile
    
        Set-Content -Path $outputfile -Value "#### Office 365 Health notification service log`n####Date Generated $(get-date)" -ErrorAction Stop
        
    }
    catch  
    {

       Write-Error -Message "Access to $outputfile is denied. Execute script as administrator for initial configuration."

       exit
    
    }
   
}

foreach ($service in $ReportServices)
{

   $ReportEvents = $Events | ? {$_.affectedservicehealthstatus.servicename -eq $Service}

   Foreach($ReportEvent in $ReportEvents)
   {

        $outputdata = 
        "$($ReportEvent.affectedservicehealthstatus.servicefeaturestatus.featurename)" + `
        " - $($ReportEvent.Status)" + `
        " - $($ReportEvent.Id) " + `
        "- LastUpdate: $($($ReportEvent.messages | `
        sort publishedtime -Descending `
        | select -First 1).publishedtime)"

        #Check to see if this event has already been reported on
        if (((get-content $outputfile) -like "*$outputdata*").count -gt 0)
        {}
        else
        {

            try 
            {

                Add-Content $outputfile "$outputdata" -ErrorAction Stop
             
            }
            catch 
            {

                Write-Error -Message "Access to $outputfile is denied. Update authorization and run again."
            
                exit
            }

            if (($reportevent.status) -eq "Service degradation" `
            -or ($reportevent.status) -like "*outage*" `
            -or ($reportevent.status) -eq "Service restored")
            {

                #Group for all Service degradation/restoration or outages
                $recipient = $priorityRecipients
            
            }
            else
            {

                #Group for all service health notifications
                $recipient = $notificationRecipients
            
            }
                
            #If the the notification is a service degregation mark the importance as high
            If ($ReportEvent.status -eq "Service degradation")
            {
                
                $Importance = "High"
            
            }
            else 
            {
                
                $Importance = "Normal"
            
            }

            $Subject = "O365 Health notification - $($ReportEvent.affectedservicehealthstatus.servicename) - $($reportevent.status) $($reportevent.id)"
            $Body = ($ReportEvent.messages | sort publishedtime -Descending | select -First 1).messagetext
            $Body = $body.Replace("`n","<br>")  

            if ($smtpserver -eq "smtp.office365.com") 
            {

                Send-MailMessage -SMTPServer $smtpserver -To $recipient -From $sender -BodyAsHtml -Subject "$Subject" `
                -Body "$Body" -Credential $creds -UseSsl  -Port 587 -Priority $Importance
                
            }
            else 
            {

                Send-MailMessage -SMTPServer $smtpserver -To $recipient -From $sender -BodyAsHtml -Subject "$Subject" `
                -Body "$Body" -Priority $Importance
            
            }

            Clear-Variable importance
        
        }

    }

}
