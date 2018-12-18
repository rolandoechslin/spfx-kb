# Original: https://ypcode.wordpress.com/2016/12/08/cross-sharepoint-platform-maintenance-tools-using-pnp-powershell/

[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True)]
    [string]$List,

    [Parameter(Mandatory=$True)]
    [string]$SourceContentType,

    [Parameter(Mandatory=$True)]
    [string]$TargetContentType
)


$ctx = Get-PnPContext
if (!$ctx) {
    Connect-PnPOnline
}

$ListObj = $null
$SourceContentTypeObj = $null
$TargetContentTypeObj = $null

# Instantiate the list object
$ListObj = Get-PnPList -Identity $List
If (!$ListObj) {
    Throw "The target list cannot be found"
}
Get-PnPProperty -ClientObject $ListObj -Property Title,ContentTypes

# Instantiate the source content type object
$SourceContentTypeObj = Get-PnPContentType -List $ListObj | ? {$_.Name -eq $SourceContentType}
If (!$SourceContentTypeObj) {
    Throw "The specified content type cannot be found in the list"
}

# Ensure the source content type name and id
Get-PnPProperty -ClientObject $SourceContentTypeObj -Property Name,Id

# Try to retrieve the target content type from the target list
$TargetContentTypeObj = Get-PnPContentType -List $ListObj | ?{$_.Name -eq $TargetContentType}

 # If the target content type does not already exist in the target list, add it
If (!$TargetContentTypeObj) {
    # Retrieve it from the available content types
    $TargetContentTypeObj = Get-PnPContentType -InSiteHierarchy | ?{$_.Name -eq $TargetContentType}
    If (!$TargetContentTypeObj) {
        Throw "The specified content type does not exists neither in list nor in site collection"
    }

    # Add the content type to the target list
    Add-PnPContentTypeToList -List $ListObj -ContentType $TargetContentTypeObj
}

# Get all items of the target list having the source content type
$camlQuery = $("<View>
                    <Query>
                        <Where>
                            <Eq>
                                <FieldRef Name='ContentType'/>
                                <Value Type='Computed'>$SourceContentType</Value>
                            </Eq>
                        </Where>
                    </Query>
                    <ViewFields>
                        <FieldRef Name='Id'/>
                        <FieldRef Name='Title'/>
                        <FieldRef Name='FileLeafRef'/>
                    </ViewFields>
                </View>")

$itemsToUpdate = Get-PnPListItem -List $ListObj -Query $camlQuery
$total = $itemsToUpdate.Count
if ($total -eq 0) {
    Write-Host "No items to migrate"
    Return
}

$progressStep = 100/$total
For ($i = 0; $i -lt $total; $i++) {
    $item = $itemsToUpdate[$i]
    $title = if ($item.Title) {$item.Title} else {$item["FileLeafRef"]}
    $itemInfo = "$title [$($item.Id)]"
    $currentProgress = ($i+1)*$progressStep
    Try
    {    
        
        $dummy = Set-PnPListItem -List $ListObj -Identity $item -ContentType $TargetContentTypeObj
        Write-Progress -Activity "Migrating Content Types" -Status "Content type of item $itemInfo has been migrated" -PercentComplete $currentProgress
    }
    Catch
    {
        Write-Progress -Activity "Migrating Content Types" -Status "Content type of item $itemInfo has not been migrated" -PercentComplete $currentProgress
        Write-Warning "Item $itemInfo cannot be fully updated."
        Write-Error $_.Error.Message
        Write-Error $_.Error.StackTrace
    }
}

Write-Progress -Activity "Migrating Content Types" -Status "Operation complete" -PercentComplete 1