# SOurce : https://veronicageek.com/office-365/sharepoint-online/find-checked-out-files-across-multiple-site-collections-and-libraries-in-spo-using-powershell-pnp/2020/02/
<#
.SYNOPSIS
    Get the checked out files.
.DESCRIPTION
    Get the checked out files from multiple sites in SharePoint Online.
    Provide a CSV file with all your sites, and the script will loop through each sites and document libraries.
.EXAMPLE
    PS C:\> .\Get-CheckedOutFiles.ps1
    Retrieve a list of all documents currently checked out in the sites you provided in the CSV, with the name of the person it's checked out to.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    None
#>
#Start Time
$startTime = "{0:G}" -f (Get-date)
Write-Host "*** Script started on $startTime ***" -f Black -b DarkYellow
# +++ CHANGE TO YOUR VALUES +++
$tenantName = "<YOUR_TENANT_NAME>"
$sitesCSV = "<PATH_FOR_CSV_FILE"
#Connect to SPO Admin Center
Connect-PnPOnline -Url "https://$tenantName-admin.sharepoint.com/"
$result = @()
$allSites = Import-Csv -Path $sitesCSV
$logFile = "C:\Users\$env:USERNAME\Desktop\CheckedOutFiles.csv"
foreach ($site in $allSites) {
    Write-Host "Connecting to: $($site.SiteUrl)" -ForegroundColor Cyan
    Connect-PnPOnline -Url $($site.SiteUrl)
    #Get all libraries
    $allLists = Get-PnPList ##If you want to target specific libraries -->> | Where-Object {($_.Title -like "documen*")}
    
    foreach ($list in $allLists) {
        $allDocs = (Get-PnPListItem -List $list) 
    
        foreach ($doc in $allDocs) {
            if ($null -ne $doc.FieldValues.CheckoutUser.LookupValue) {
                $result += [PSCustomObject][ordered]@{
                    Site            = $site.SiteName
                    Library         = $list.Title
                    FileName        = $doc["FileLeafRef"]
                    CheckedOutTo    = $doc.FieldValues.CheckoutUser.LookupValue
                    FullLocation    = $doc["FileRef"]
                }
            }
        }
    }
}
$result | Export-Csv -Path $logFile -NoTypeInformation
#End Time
$endTime = "{0:G}" -f (Get-date)
Write-Host "*** Script finished on $endTime ***" -f Black -b DarkYellow
Write-Host "Time elapsed: $(New-Timespan $startTime $endTime)" -f White -b DarkRed