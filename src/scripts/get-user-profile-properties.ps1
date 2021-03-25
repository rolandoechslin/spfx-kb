# https://techcommunity.microsoft.com/t5/microsoft-365-pnp-blog/fetch-user-profile-properties-from-site-collection-and-export-to/ba-p/2232136

$basePath = #base path where you want to save CSV file("D:\Chandani\...\")
$dateTime = "{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$csvPath = $basePath + "\userdetails" + $dateTime + ".csv"
$adminSiteURL = "https://****-admin.sharepoint.com/" #O365 admin site URL
$username = #user email id
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$global:userDetails = @()
$index = 1;
$userInfo;
  
Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Creds)
 
    #connect to O365 admin site
    Write-Host "Connecting to Tenant Admin Site '$($adminSiteURL)'" -f Yellow | Out-File $LogFile -Append -Force
  
    Connect-PnPOnline -Url $adminSiteURL -Credentials $Creds
    Write-Host "Connection Successfull" -f Yellow | Out-File $LogFile -Append -Force
   
}
Function StartProcessing {
    Login($Creds);
    ConnectionToSite($Creds)
}

Function ConnectionToSite() {
    $siteURL = Read-Host "Please enter site collcetion URL" 
  
    try {            
        Write-Host "Connecting to Site '$($siteURL)'" -f Yellow          
                              
        $SCWeb = Get-PnPWeb -Identity ""              
                                                     
        $getusers = Get-PnPUser -Web $SCWeb

        ForEach ($user in $getusers) { 
            $email = $user.Email
            If ($email) {
                $userInfo = GetUserProfileProperties $email        
                #creating object fro CSV
                $global:userDetails += New-Object PSObject -Property ([ordered]@{                   
                        Id            = $index
                        GUID          = $userInfo.'UserProfile_GUID'
                        FirstName     = $userInfo.FirstName
                        LastName      = $userInfo.LastName
                        WorkEmail     = $userInfo.WorkEmail 
                        PictureURL    = $userInfo.PictureURL    
                        Department    = $userInfo.Department
                        PreferredName = $userInfo.PreferredName                        
                    })
                $index++ 
            } 
        }                                                                
    }
    catch {
        Write-Host -f Red "Error in connecting to Site '$($TenantSite)'"                        
    }                                     
    BindingtoCSV($global:userDetails) 
}

Function BindingtoCSV {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Global)   
    Write-Host -f Yellow "Exporting to CSV..."
    $userDetails | Export-Csv $csvPath -NoTypeInformation -Append
    Write-Host -f Yellow "Exported Successfully..."
}

Function GetUserProfileProperties($username) {
    $Properties = Get-PnPUserProfileProperty -Account $username
    $Properties = $Properties.UserProfileProperties
   
    If ($Properties) {
        $Properties = $Properties
    }
    else {
        $Properties = $null
    }
    return $Properties
}

StartProcessing