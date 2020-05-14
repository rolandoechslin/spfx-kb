# Source: https://techcommunity.microsoft.com/t5/office-365-groups/quot-my-groups-quot-list-for-sharepoint-homepage-web-part/m-p/44824

# SharePoint Online DLLs
#$dllDirectory = "D:\Assets\\16.1.6112.1200"
$dllDirectory = "C:\PowerShell\DLL\16.1.6112.1200"
Add-Type -Path "$dllDirectory\Microsoft.SharePoint.Client.dll" 
Add-Type -Path "$dllDirectory\Microsoft.SharePoint.Client.Runtime.dll" 

# User Credentials and Variables 
$username = "<admin username here>"
$password = '<admin password here>'
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force 
$url = "https://contoso.sharepoint.com/sites/groups/" # the url of the site where your list is
$listName = "Groups" # the name of your list
$domain = "@contoso.com"

# Connect to Exchange Online
Write-Host "Connecting to Exchange Online..." -ForegroundColor Green 
$E_Credential = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $E_Credential -Authentication Basic -AllowRedirection
Import-PSSession $Session -AllowClobber  | out-null

# Connect to SPO
$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($url) 
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $securePassword) 
$clientContext.Credentials = $credentials 
Write-Host "Connected to: '$Url'" -ForegroundColor Green 
	
$List = $clientContext.Web.Lists.getByTitle($listName)
$clientContext.Load($List)
$clientContext.ExecuteQuery()

# Get Existing Entries
$spQuery = New-Object Microsoft.SharePoint.Client.CamlQuery	
$items = $List.GetItems($spQuery)
$clientContext.Load($items)
$clientContext.ExecuteQuery()

# Remove Existing Entries
Write-Host "Clearing existing entries" -ForegroundColor Cyan
$count = 0
ForEach ($item in $items){
    Write-Host ("  "+$count+" "+$Item.FieldValues["ID"]+" "+$Item.FieldValues["Title"])
    $List.getitembyid($Item.id).DeleteObject()
    $clientContext.ExecuteQuery()
    $count += 1
}

# Get all O365 Groups
Write-Host "Getting O365 Groups" -ForegroundColor Cyan
$o365Groups = get-unifiedgroup
$count = 0
foreach($group in $o365Groups){
    $count++
    Write-Host "$count - Creating $($group.DisplayName)" -ForegroundColor Green
    #$group | select * # Show all available Group details

    $O365_group = $clientContext.Site.RootWeb.EnsureUser("c:0o.c|federateddirectoryclaimprovider|$($group.ExternalDirectoryObjectId)")
    $clientContext.Load($O365_group)

    [Microsoft.SharePoint.Client.FieldUserValue[]]$groupOwners = New-Object Microsoft.SharePoint.Client.FieldUserValue
    $owners = ($group.ManagedBy)
    foreach($owner in $owners){
        try{
            $user = $clientContext.Web.EnsureUser("$owner@buckman.com")
            $clientContext.Load($user)
		    $clientContext.ExecuteQuery()	                    
            [Microsoft.SharePoint.Client.FieldUserValue]$fieldUser = New-Object Microsoft.SharePoint.Client.FieldUserValue
            $fieldUser.LookupId = $user.Id
            if($counter -eq 0){
                $groupOwners = $fieldUser
            } else {
                $groupOwners += $fieldUser
            }
            $counter++
        } catch {
            Write-Host "User does not exist"
        }
    }


    # Create new entry in SharePoint List
    # Change the ["field"] values to match your SharePoint column internal names
    $ListItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
    $newItem = $List.AddItem($ListItemInfo)
    $newItem["Title"] = $group.DisplayName # Single Line of Text
    $newItem["Group"] = $O365_group # Person/Group Field (Group enabled)    
    $newItem["Description"] = $group.Notes # Multiple Lines of Text
    $newItem["Conversation"] = "https://outlook.office.com/owa/?path=/group/$($group.Alias)$($domain)/mail, Conversation" # Hyperlink
    $newItem["Calendar"] = "https://outlook.office.com/owa/?path=/group/$($group.Alias)$($domain)/calendar, Calendar" # Hyperlink
    $newItem["Files"] = "https://outlook.office.com/owa/?path=/group/$($group.Alias)$($domain)/files, Files" # Hyperlink
    $newItem["Library"] = "$($group.SharePointDocumentsUrl), Document Library" # Hyperlink
    $newItem["Site"] = "$($group.SharePointSiteUrl), SharePoint Site" # Hyperlink
    $newItem["Notebook"] = "$($group.SharePointNotebookUrl), Notebook" # Hyperlink
    $newItem["Category"] = $group.Classification # Single Line of Text
    $newItem["Connectors"] = $group.ConnectorsEnabled # Boolean (Yes/No)
    $newItem["HiddenFromGAL"] = $group.HiddenFromAddressListsEnabled # Boolean (Yes/No)
    $newItem["Language"] = $group.Language # Single Line of Text
    $newItem["Privacy"] = $group.AccessType # Single Line of Text
    $newItem["DynamicMembership"] = $group.IsMembershipDynamic # Boolean (Yes/No)
    $newItem["ExternalDirectoryID"] = $group.ExternalDirectoryObjectId # Single Line of Text   
    $newItem["ExternalUserCount"] = $group.GroupExternalMemberCount # Number   
    $newItem["Owners"] = $groupOwners # Multiple Person Field
    # Add more as needed
    $newItem.Update()
    $clientContext.ExecuteQuery()

    # Break Permissions
    $newItem.BreakRoleInheritance($false, $false)  
    $clientContext.ExecuteQuery()  

    # Remove Any Existing Permissions
    $permissions = $newItem.RoleAssignments
    $clientContext.Load($permissions)
    $clientContext.ExecuteQuery()
    foreach($permission in $permissions){
        $newItem.RoleAssignments.GetByPrincipalId($permission.PrincipalId).DeleteObject()
    }

    # Set permissions to actual O365 Group
    $reader = $clientContext.Web.RoleDefinitions.GetByName("Read");
    $roleAssignment = New-Object microsoft.SharePoint.Client.RoleDefinitionBindingCollection($clientContext)
	$roleAssignment.Add($reader)
    $clientContext.Load($newItem.RoleAssignments.Add($O365_group, $roleAssignment)) 
                                     
    $newItem.Update();  
    $clientContext.ExecuteQuery()

}
