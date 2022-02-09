# SOurce: https://techcommunity.microsoft.com/t5/microsoft-365-pnp-blog/how-to-get-any-site-collection-users-with-their-roles-using-pnp/ba-p/2267307?WT.mc_id=m365-24198-cxa

$basePath = "E:\Chandani\Blogs\UserRolesPS\"
$dateTime = "{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$csvPath = $basePath + "\userdetails" + $dateTime + ".csv"
$adminSiteURL = "https://*****-admin.sharepoint.com/" #O365 admin site URL
$username = #Email ID
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$global:userRoles = @()


Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Creds)
 
    #connect to the O365 admin site
    Write-Host "Connecting to Tenant Admin Site '$($adminSiteURL)'" -f Yellow
  
    Connect-PnPOnline -Url $adminSiteURL -Credentials $Creds
    Write-Host "Connection Successfull" -f Yellow 
   
}
Function StartProcessing {
    Login($Creds);
    GetUserRoles
}

Function GetUserRoles {
    try {
        $siteURL = Read-Host "Please enter site collcetion URL"
        Write-Host "Connecting to Site '$($siteURL)'" -f Yellow          
     
        Connect-PnPOnline -Url $siteURL -Credentials $Creds
    
        $web = Get-PnPWeb -Includes RoleAssignments
    
        foreach ($roles in $web.RoleAssignments) {
            $member = $roles.Member
            $loginName = get-pnpproperty -ClientObject $member -Property LoginName
            $title = get-pnpproperty -ClientObject $member -Property Title
            $rolebindings = get-pnpproperty -ClientObject $roles -Property RoleDefinitionBindings
            $roleName = $($rolebindings.Name)            
    
            $global:userRoles += New-Object PSObject -Property ([ordered]@{                   
                    UserName  = $title
                    LoginName = $loginName
                    Roles     = $roleName
                })            
        }       
    }
    catch {
        Write-Host -f Red "Error in connecting to Site '$($TenantSite)'"     
    } 
    Write-Host "Exporting to CSV" -ForegroundColor Yellow      
    $global:userRoles | Export-CSV $csvPath -NoTypeInformation
    Write-Host "Export to CSV successfully!" -ForegroundColor Yellow
}

StartProcessing