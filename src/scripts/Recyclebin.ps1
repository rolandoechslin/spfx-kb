# USE AT YOUR OWN RISK (Standard Disclaimer)

# This script was create to recursively restore a folder in the

# first stage recycle bin when you have too many items in your Recycle Bin

# Getting "The attempted operation is prohibited because it exceeds the list view threshold enforce by administrator" Error

# Required Module:

# Install-Module SharePointPnPPowerShellOnline

# Credit to : https://lazyadmin.nl/powershell/restore-recycle-bin-sharepoint-online-with-powershell/

# Refer to link for help with filtering by user or data.

#CHANGE FOLLOWING VARIABLES TO MATCH YOUR ENVIRONMENT

# YOUR SHAREPOINT SITE

$siteUrl = "https://mydomain.sharepoint.com/sites/Assholes"

# The Folder to Restore - Full Path

$directoryToRestore = ''

# A number higher than your count in the recyclebin

# You can use a high number, just know it will take longer to get

# the restoreSet

$maxRows = 400000

$today = (Get-Date)

$date1 = $today

$date2 = $today.date.addDays(-7)

echo $date1

echo $date2

# -UseWebLogin used for 2 factor Auth. You can remove if you don't have MFA turned on

Connect-PnPOnline -Interactive -Url $siteUrl

$restoreSet = Get-PnPRecycleBinItem -FirstStage -RowLimit $maxRows | ? {($_.DeletedDate -gt $date2 -and $_.DeletedDate -lt $date1) -and ($_.DeletedByEmail -eq 'dumbass@mydomain.xyz')}

$restoreSet = $restoreSet | Sort-Object -Property @{expression ='ItemType'; descending = $true},@{expression = "DirName"; descending = $false} , @{expression = "LeafName"; descending = $false}

$restoreSet.Count

# Batch restore up to 200 at a time

$restoreList = $restoreSet | select Id, ItemType, LeafName, DirName

$apiCall = $siteUrl + "/_api/site/RecycleBin/RestoreByIds"

$restoreListCount = $restoreList.count

$start = 0

$leftToProcess = $restoreListCount - $start

while($leftToProcess -gt 0){

If($leftToProcess -lt 200){$numToProcess = $leftToProcess} Else {$numToProcess = 200}

Write-Host -ForegroundColor Yellow "Building statement to restore the following $numToProcess files"

$body = "{""ids"":["

for($i=0; $i -lt $numToProcess; $i++){

$cur = $start + $i

$curItem = $restoreList[$cur]

$Id = $curItem.Id

Write-Host -ForegroundColor Green "Adding ", $curItem.ItemType, ": ", $curItem.DirName, "//", $curItem.LeafName

$body += """" + $Id + """"

If($i -ne $numToProcess - 1){ $body += "," }

}

$body += "]}"

Write-Host -ForegroundColor Yellow $body

Write-Host -ForegroundColor Yellow "Performing API Call to Restore items from RecycleBin..."

try {

Invoke-PnPSPRestMethod -Method Post -Url $apiCall -Content $body | Out-Null

}

catch {

Write-Error "Unable to Restore"

}

$start += 200

$leftToProcess = $restoreListCount - $start

}