# PnP Powershell

## Login with Application admin

 -[The required Office 365 role to run PnP Powershell with Scopes](https://sharepoint-tricks.com/the-required-office-365-role-to-run-pnp-powershell-with-scopes/)

## Installation Options

- [Running multiple versions of PnP-PowerShell](https://blog.pixelmill.com/3718/running-multiple-versions-of-pnp-powershell/)

## Documentation

- [sharepoint-pnp-cmdlets](https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets?view=sharepoint-ps)

## Specific Version

- [Import a specific module from the installed SharePoint PnP PowerShell modules (2013, 2016, 2019 & Online)](http://blog.meenavalli.in/post/powershell-import-a-specific-module-from-the-installed-sharepoint-pnp-powershell-modules-2013-2016-2019-and-online)
- [Run PnP PowerShell with saved module](https://sharepoint-tricks.com/run-pnp-powershell-without-install-module/)

## Latest Version

- [Latest Release Version](https://github.com/SharePoint/PnP-PowerShell/releases/latest)
- [Change Log](https://github.com/SharePoint/PnP-PowerShell/blob/master/CHANGELOG.md)

## Check

```Powershell
Get-InstalledModule | foreach { $b = (find-module $_.name).version ; if ($b -ne $_.version) { Write-host "$($_.name) has an update from $($_.version) to $b" } }
```

```Powershell
Get-Module SharePointPnPPowerShell* -ListAvailable | Select-Object Name,Version | Sort-Object Version -Descending
```

## Update Module to latest version

```Powershell
Update-Module SharePointPnPPowerShell*
```

## Delete old version

```Powershell
Get-InstalledModule -Name "SharePointPnPPowerShellOnline" -RequiredVersion 3.8.1904.0 | Uninstall-Module
```

## Install specific version

```Powershell
Install-Module -Name SharePointPnPPowerShellOnline -RequiredVersion 3.0.1808.1
```

## Connect with App Permission

- [Introduction to Initialize-PnPPowerShellAuthentication cmdlet](https://www.youtube.com/watch?v=QWY7AJ2ZQYI)

```Powershell
Initialize-PnPPowerShellAuthentication -ApplicationName DemoApp -Tenant tenant.onmicrosoft.com -Store CurrentUser

$url = "https://tenant.sharepoint.com"
$clientid = "<placeholder>"
$thumbprint = "<placeholder>"
$tenant = 'tenant.onmicrosoft.com'

Connect-PnPOnline -Url $url -ClientId $clientid -Thumbprint $thumbprint -Tenant $tenant
```

```Powershell
# Load PNP the Right Way
$pnp = Get-Command Connect-Stuff -ErrorAction SilentlyContinue
if (!$pnp) {Install-Module SharePointPnPPowerShellOnline -Force}
Import-Module SharePointPnPPowerShellOnline
```

## List all commands

```Powershell
Get-Command | ? { $_.ModuleName -eq "SharePointPnPPowerShellOnline" }
```

## Create Guid

```Powershell
[guid]::NewGuid() | Select-Object -ExpandProperty Guid | clip
```

## Delete all listitems 

```Powershell
Get-PnPList -Identity Lists/MyList | Get-PnPListItem -PageSize 100 -ScriptBlock { Param($items) 
$items.Context.ExecuteQuery() } | % {$_.DeleteObject()}
```

## Upload Documents

- https://gallery.technet.microsoft.com/office/Upload-Multiple-Documents-4c4aa989

```Powershell
function UploadDocuments(){
Param(
        [ValidateScript({If(Test-Path $_){$true}else{Throw "Invalid path given: $_"}})] 
        $LocalFolderLocation,
        [String] 
        $siteUrl,
        [String]
        $documentLibraryName
)
Process{
        $path = $LocalFolderLocation.TrimEnd('\')

        Write-Host "Provided Site :"$siteUrl -ForegroundColor Green
        Write-Host "Provided Path :"$path -ForegroundColor Green
        Write-Host "Provided Document Library name :"$documentLibraryName -ForegroundColor Green

          try{
                $credentials = Get-Credential
  
                Connect-PnPOnline -Url $siteUrl -CreateDrive -Credentials $credentials

                $file = Get-ChildItem -Path $LocalFolderLocation -Recurse
                $i = 0;
                Write-Host "Uploading documents to Site.." -ForegroundColor Cyan
                (dir $path -Recurse) | %{
                    try{
                        $i++
                        if($_.GetType().Name -eq "FileInfo"){
                          $SPFolderName =  $documentLibraryName + $_.DirectoryName.Substring($path.Length);
                          $status = "Uploading Files :'" + $_.Name + "' to Location :" + $SPFolderName
                          Write-Progress -activity "Uploading Documents.." -status $status -PercentComplete (($i / $file.length)  * 100)
                          $te = Add-PnPFile -Path $_.FullName -Folder $SPFolderName
                         }          
                        }
                    catch{
                    }
                 }
            }
            catch{
             Write-Host $_.Exception.Message -ForegroundColor Red
            }

  }
}


#UploadDocuments -LocalFolderLocation {Local Folder Location} -siteUrl {Site collection URL} -documentLibraryName {Document Library Name}
```

## Site Classification

- https://www.jijitechnologies.com/blogs/site-classification-using-pnp-powershell

```Powershell
Connect-PnPOnline -Scopes "Directory.ReadWrite.All"
```

```Powershell
Enable-PnPSiteClassification -Classifications "HBI","LBI","Top Secret" -UsageGuidelinesUrl ```
"http://aka.ms/sppnp" -DefaultClassification "HBI"
```

```Powershell
Add-PnPSiteClassification -Classifications "SBI","MBI"
```

```Powershell
Remove-PnPSiteClassification -Classifications "SBI"
```

```Powershell
Update-PnPSiteClassification -Classifications "HBI","LBI","Top Secret" -UsageGuidelinesUrl http://aka.ms/sppnp" -DefaultClassification "HBI"
```

```Powershell
Disable-PnPSiteClassification
```

## Tips

- [Add QuickLinks with powershell-pnp](https://sharepoint.stackexchange.com/questions/241689/add-quicklinks-with-powershell-pnp/241707#241707)

## Documents List

- [Change the New Menu in SharePoint Online Documents List](https://cann0nf0dder.wordpress.com/2019/03/24/programmatically-change-the-new-menu-in-sharepoint-online-using-powershell/)

## List Properties

- [Finding Missing Properties in PnP PowerShell](https://www.toddklindt.com/blog/Lists/Posts/Post.aspx?List=56f96349%2D3bb6%2D4087%2D94f4%2D7f95ff4ca81f&ID=851&Web=48e6fdd1%2D17db%2D4543%2Db2f9%2D6fc7185484fc)

```Powershell
Connect-PnPOnline -Url https://toddklindt.sharepoint.com/sites/8884aced -Credentials Me
Get-PnPView -List Documents
Get-PnPView -List Documents -Identity 3c4126aa-d2fe-4b57-9a70-e03ebb9c76ef
$view = Get-PnPView -List Documents -Identity 3c4126aa-d2fe-4b57-9a70-e03ebb9c76ef
$view
$view | select *
$view.ViewQuery
Get-PnPProperty -ClientObject $view -Property ViewQuery
$view.ViewQuery
$view
$view | select *
```

## LookUp Fields

- [How to: Provision Lookup Columns and Projected Fields using PnP PowerShell](https://coreyroth.com/2019/06/27/how-to-provision-lookup-columns-and-projected-fields-using-pnp-powershell/)
- [PnPPowerShellLookupColumns](https://github.com/coreyroth/PnPPowerShellLookupColumns)
