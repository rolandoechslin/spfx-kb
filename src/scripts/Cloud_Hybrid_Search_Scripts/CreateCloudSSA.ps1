<#
.SYNOPSIS
    This script is being provided as a sample for the creation of a single box cloud SSA, or a high-available cloud SSA across 2 boxes.
    Note: SearchServiceAccount needs to already exist in Windows Active Directory as per TechNet Guidelines https://technet.microsoft.com/library/gg502597.aspx
.PARAMETER SearchServerName
    SharePoint On-Prem search installation server name.
.PARAMETER SearchServerName2
    SharePoint On-Prem search installation server 2 name, which is optional. This input is necessary if a high-available cloud SSA solution is needed.
.PARAMETER SearchServiceAccount
    SharePoint On-Prem search installation admin account.
.PARAMETER SearchServiceAppName
    The name of cloud SearchServiceApplication (SSA) to be created by this script.
.PARAMETER DatabaseServerName
    SharePoint On-Prem database installation server name.
.LAST UPDATED
    2018-06-19
#>
Param( 
    [Parameter(Mandatory=$true)][string] $SearchServerName,
    [Parameter(Mandatory=$false)][string] $SearchServerName2, 
    [Parameter(Mandatory=$true)][string] $SearchServiceAccount, 
    [Parameter(Mandatory=$true)][string] $SearchServiceAppName, 
    [Parameter(Mandatory=$true)][string] $DatabaseServerName 
) 
Add-PSSnapin Microsoft.SharePoint.Powershell -ea 0 

# Check existing cloud SSA in the farm.
$cloudSsa = Get-SPEnterpriseSearchServiceApplication | Where { $_.CloudIndex -eq $true }
if ($cloudSsa -ne $null) {
	if ($cloudSsa.Count -eq 1) {
		if ($cloudSsa.Name -eq $SearchServiceAppName)
		{
			Write-Host "A cloud SSA with name '$($cloudSsa.Name)' already exists, thus skip cloud SSA creation." -Foreground Green
			return
		}
		else
		{
			throw "A cloud SSA with name '$($cloudSsa.Name)' already exists. Only 1 cloud SSA is supported per SharePoint farm. Please either reuse the existing cloud SSA '$($cloudSsa.Name)' or remove it first and create a new cloud SSA with name '$SearchServiceAppName'."
		}
	}
	else
	{
		throw "More than 1 cloud SSA found. Only 1 cloud SSA is supported per SharePoint farm. Please make sure only 1 cloud SSA exists."		
	}
} 

## Validate if the supplied account exists in Active Directory and whether it’s supplied as domain\username 

if ($SearchServiceAccount.Contains("\")) # if True then domain\username was used 
{ 
    $Account = $SearchServiceAccount.Split("\") 
    $Account = $Account[1] 
} 
else # no domain was specified at account entry 
{ 
    $Account = $SearchServiceAccount 
} 

$domainRoot = [ADSI]'' 
$dirSearcher = New-Object System.DirectoryServices.DirectorySearcher($domainRoot) 
$dirSearcher.filter = "(&(objectClass=user)(sAMAccountName=$Account))" 
$results = $dirSearcher.findall() 

if ($results.Count -gt 0) # Test for user not found 
{  
    Write-Output "Active Directory account $Account exists. Proceeding with configuration." 

	## Validate whether the supplied SearchServiceAccount is a managed account. If not make it one. 

	if(Get-SPManagedAccount | ?{$_.username -eq $SearchServiceAccount})  
    { 
        Write-Output "Managed account $SearchServiceAccount already exists!" 
    } 
    else 
    { 
        Write-Output "Managed account does not exist - creating it."
        $ManagedCred = Get-Credential -Message "Please provide the password for $SearchServiceAccount" -UserName $SearchServiceAccount 

        try 
        { 
        New-SPManagedAccount -Credential $ManagedCred 
        } 
        catch 
        { 
         Write-Output "Unable to create managed account for $SearchServiceAccount. Please validate user and domain details." 
         break 
         } 

    } 
Write-Output "Creating Application Pool."  
$appPoolName=$SearchServiceAppName+"_AppPool" 
$appPool = New-SPServiceApplicationPool -name $appPoolName -account $SearchServiceAccount 
if ($appPool -eq $null)
{
	throw "Could not create a new app pool with name [$appPoolName] and account [$SearchServiceAccount]. Please check if the parameters are valid."		
}

Write-Output "Starting Search Service Instance One." 
Start-SPEnterpriseSearchServiceInstance $SearchServerName 

if($SearchServerName2)
{
	Write-Output "Starting Search Service Instance Two." 
	Start-SPEnterpriseSearchServiceInstance $SearchServerName2
}

Write-Output "Creating cloud Search service application." 
$searchApp = New-SPEnterpriseSearchServiceApplication -Name $SearchServiceAppName -ApplicationPool $appPool -DatabaseServer $DatabaseServerName -CloudIndex $true 
if ($searchApp -eq $null)
{
	throw "Could not create a new search service application with name [$SearchServiceAppName], app pool [$appPool], database server [$DatabaseServerName] and CloudIndex flag [true]. Please check if the parameters are valid."		
}

Write-Output "Configuring search administration component." 
$searchInstance = Get-SPEnterpriseSearchServiceInstance $SearchServerName 
$searchApp | get-SPEnterpriseSearchAdministrationComponent | set-SPEnterpriseSearchAdministrationComponent -SearchServiceInstance $searchInstance 
$admin = ($searchApp | get-SPEnterpriseSearchAdministrationComponent) 

Write-Output "Waiting for the search administration component to be initialized." 
$timeoutTime=(Get-Date).AddMinutes(20) 
do {Write-Output .;Start-Sleep 10;} while ((-not $admin.Initialized) -and ($timeoutTime -ge (Get-Date))) 
if (-not $admin.Initialized) { throw 'Admin Component could not be initialized'} 

Write-Output "Inspecting cloud Search service application." 
$searchApp = Get-SPEnterpriseSearchServiceApplication $SearchServiceAppName 


#Output some key properties of the Search service application 
Write-Host "Search Service Properties"  
Write-Host " Cloud SSA Name    : " $searchapp.Name 
Write-Host " Cloud SSA Status  : " $searchapp.Status 
Write-Host "Cloud Index Enabled      : " $searchApp.CloudIndex 

Write-Output "Configuring search topology." 
$searchApp = Get-SPEnterpriseSearchServiceApplication $SearchServiceAppName 
$topology = $searchApp.ActiveTopology.Clone() 

$oldComponents = @($topology.GetComponents()) 
if (@($oldComponents  | ? { $_.GetType().Name -eq "AdminComponent" }).Length -eq 0) 
{ 
    $topology.AddComponent((New-Object Microsoft.Office.Server.Search.Administration.Topology.AdminComponent $SearchServerName)) 
} 
$topology.AddComponent((New-Object Microsoft.Office.Server.Search.Administration.Topology.CrawlComponent $SearchServerName))
$topology.AddComponent((New-Object Microsoft.Office.Server.Search.Administration.Topology.ContentProcessingComponent $SearchServerName)) 
$topology.AddComponent((New-Object Microsoft.Office.Server.Search.Administration.Topology.AnalyticsProcessingComponent $SearchServerName)) 
$topology.AddComponent((New-Object Microsoft.Office.Server.Search.Administration.Topology.QueryProcessingComponent $SearchServerName)) 
$topology.AddComponent((New-Object Microsoft.Office.Server.Search.Administration.Topology.IndexComponent $SearchServerName,0)) 

if($SearchServerName2)
{
	$topology.AddComponent((New-Object Microsoft.Office.Server.Search.Administration.Topology.AdminComponent $SearchServerName2))
	$topology.AddComponent((New-Object Microsoft.Office.Server.Search.Administration.Topology.CrawlComponent $SearchServerName2))
	$topology.AddComponent((New-Object Microsoft.Office.Server.Search.Administration.Topology.ContentProcessingComponent $SearchServerName2))
	$topology.AddComponent((New-Object Microsoft.Office.Server.Search.Administration.Topology.AnalyticsProcessingComponent $SearchServerName2))
	$topology.AddComponent((New-Object Microsoft.Office.Server.Search.Administration.Topology.QueryProcessingComponent $SearchServerName2))
	$topology.AddComponent((New-Object Microsoft.Office.Server.Search.Administration.Topology.IndexComponent $SearchServerName2,0)) 
}

$oldComponents  | ? { $_.GetType().Name -ne "AdminComponent" } | foreach { $topology.RemoveComponent($_) } 

Write-Output "Activating topology." 
$topology.Activate() 
$timeoutTime=(Get-Date).AddMinutes(20) 
do {Write-Output .;Start-Sleep 10;} while (($searchApp.GetTopology($topology.TopologyId).State -ne "Active") -and ($timeoutTime -ge (Get-Date))) 
if ($searchApp.GetTopology($topology.TopologyId).State -ne "Active")  { throw 'Could not activate the search topology'} 

Write-Output "Creating proxy." 
$searchAppProxy = new-spenterprisesearchserviceapplicationproxy -name ($SearchServiceAppName+"_proxy") -SearchApplication $searchApp 

Write-Output "Cloud search service application provisioning completed successfully." 

} 
else # The Account Must Exist so we can proceed with the script 
{
	Write-Output "Account supplied for Search Service does not exist in Active Directory." 
	Write-Output "Script is quitting. Please create the account and run again." 
	Break 
} # End Else 

