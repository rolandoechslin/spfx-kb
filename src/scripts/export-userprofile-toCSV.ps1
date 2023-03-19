# https://pnp.github.io/script-samples/spo-export-upa-accounts/README.html

$adminsiteUrl = "https://contoso-admin.sharepoint.com/"
$conn = Connect-PnPOnline -Url $adminsiteUrl -Interactive -ReturnConnection
Connect-AzAccount
$AllUsers = Get-AzADUser 
$Counter = 0
$AllUsers.Count
$UserProfileData = @()
$emaildomain = "@contoso.com"


ForEach($User in $AllUsers)
{
        #filter out those account you dont need
        if($User.ObjectType -ne "User")
        {
            continue
        }
        # exclude those without an email address that matches this domain
        if($null -eq $User.Mail -or $User.Mail.IndexOf($emaildomain) -eq -1 )
        {
            continue
        }
        
        
        Write-host "`nGetting User Profile Property for: $($User.UserPrincipalName)" -f Yellow
        #Get the User Property value from SharePoint 
        try 
        {
            $UserProfile = Get-PnPUserProfileProperty -Account ($User.UserPrincipalName) -Connection $conn
            $UserProfile.UserProfileProperties["Department"]
            
            # Yet another option to exclude account from the export. Here we exclude account without a value in the Department field
            if($null -eq $UserProfile.UserProfileProperties["Department"] -or $UserProfile.UserProfileProperties["Department"] -eq "")
            {
                continue
            }
            #Get User Profile Data
            $UserData = New-Object PSObject
            ForEach($Key in $UserProfile.UserProfileProperties.Keys)
            { 
                $UserData | Add-Member NoteProperty $Key($UserProfile.UserProfileProperties[$Key])
            }
            $UserProfileData += $UserData
            $Counter++
            Write-Progress -Activity "Getting User Profile Data..." -Status "Getting User Profile $Counter of $($AllUsers.Count)" -PercentComplete (($Counter / $AllUsers.Count)  * 100)
        
        }
        catch 
        {
            Write-Host $_.Exception.Message
            
        }     
        

}
#Export the data to CSV
$CSVPath = "C:\temp\UPAAccounts.csv"
$UserProfileData | Export-Csv $CSVPath -Encoding utf8BOM -Delimiter "|"
   
write-host -f Green "User Profiles Data Exported Successfully to:" $CSVPath
