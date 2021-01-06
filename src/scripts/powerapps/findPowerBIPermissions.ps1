#****************
#------------------------------------------------------
# --> PBI WORKSPACES & PERMISSIONS
#
# Export PBI results to grid for copy/paste to Excel table
# * All groups (Active/Deleted)
# * All workspaces (Active)
# * All workspace permissions
#
# RestAPI call for each workspace (Group Users) 
# * https://docs.microsoft.com/en-us/rest/api/power-bi/groups/getgroupusers
#
#------------------------------------------------------ 


#****************
#------------------------------------------------------
# --> PBI Connection
#------------------------------------------------------ 
Write-Host " PBI credentials ..." -ForegroundColor Yellow -BackgroundColor DarkGreen

## PBI credentials 

$password = "myPassword" | ConvertTo-SecureString -asPlainText -Force
$username = "myemail@domain.com" 
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

## PBI connect 

Connect-PowerBIServiceAccount -Credential $credential

# Login-PowerBI


#****************
#------------------------------------------------------
# --> Workspace info 
# 
# * Get-PowerBIWorkspace > "WARNING: Defaulted to show top 100 workspaces. Use -First & -Skip or -All to retrieve more results."
# * Grid exported for workspaces
#------------------------------------------------------ 
Write-Host " Workspace info ..." -ForegroundColor Yellow -BackgroundColor DarkGreen
    
## List all groups, Select ID desired for Variables section 
## PBIWorkspace properties values are NULL if Scope is not set to Organization 
# Get-PowerBIWorkspace -Scope Organization -Filter "tolower(name) eq 'BI Team POC - DEV'" 

# SET
$Groups = Get-PowerBIWorkspace -Scope Organization -All | SORT @{Expression="Type"; Descending=$True}, Name

$Groups_deleted = $Groups | SELECT Id, Name, Type, State | WHERE State -EQ 'Deleted'
$Groups = $Groups | SELECT Id, Name, Type, State | WHERE State -NE 'Deleted'
$GroupWorkspaces = $Groups | WHERE Type -eq 'Workspace' 

# PRINT
$Groups_deleted | Select Id, Name, Type, State | ft –auto 
$Groups | Select Id, Name, Type, State | ft –auto 
$GroupWorkspaces | Select Id, Name, Type | ft –auto 
Get-PowerBIWorkspace -Scope Organization -Name "BI Team Sandbox" | Select Id, Name, Type | ft –auto 

# OUT GRID
$GroupsWorkspaces | Select Id, Name, Type | Out-GridView 
$Groups | Select Id, Name, Type | Out-GridView
$Groups_deleted | Select Id, Name, Type, State | Out-GridView


#------------------------------------------------------ 
## LOOP FOLDERS ##################
# * RestAPI call for each workspace (Group Users) 
# * Grid exported for workspace user access
#------------------------------------------------------ 

# Clear variable before loop to reseat array data collector 
clear-variable -name WorkspaceUsers

Write-Host " Looping ..." -ForegroundColor Yellow -BackgroundColor DarkGreen

foreach ($GroupWorkspaceId in $GroupWorkspaces.Id) {

    $WorkspaceObject = Get-PowerBIWorkspace -Scope Organization -Id $GroupWorkspaceId
    $pbiURL = "https://api.powerbi.com/v1.0/myorg/groups/$GroupWorkspaceId/users"
    $WorkspaceObject | Select Id, Name, Type | ft –auto 

    Write-Host ($WorkspaceObject.Name +" | "+ $WorkspaceObject.Type)  -ForegroundColor White -BackgroundColor Blue
    Write-Host $GroupWorkspaceId -ForegroundColor White -BackgroundColor Blue
    Write-Host $pbiURL -ForegroundColor White -BackgroundColor Blue


#****************
#------------------------------------------------------
# --> 1. API Call for WORKSPACE USERS  
#------------------------------------------------------ 
    Write-Host " API Call ..." -ForegroundColor Yellow -BackgroundColor DarkGreen
     
    ## API call
    $resultJson = Invoke-PowerBIRestMethod –Url $pbiURL –Method GET 
    $resultObject = ConvertFrom-Json -InputObject $resultJson 

    ## Collect data fields for each loop
    $WorkspaceUsers += $resultObject.Value | 
    SELECT @{n='WorkspaceId';e={$GroupWorkspaceId}}, 
            @{n='Workspace';e={$WorkspaceObject.Name}}, 
            displayName, 
            emailAddress, 
            @{n='UserRole';e={$_.groupUserAccessRight}}, 
            @{n='Principle';e={$_.principalType}} |
        SELECT Workspace, displayName, UserRole, Principle, emailAddress | 
        SORT UserRole, displayName 
    
    ## Print loop results
    $WorkspaceUsers | ft -auto | Where{$_.WorkspaceId -eq $GroupWorkspaceId} 

    clear-variable -name resultJson
    clear-variable -name resultObject

}
## END LOOP  ##################
#------------------------------------------------------ 

## Export user access for all workspaces
    $WorkspaceUsers | SORT Workspace, UserRole, displayName | Out-GridView 