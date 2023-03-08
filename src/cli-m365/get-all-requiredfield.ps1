$siteUrl = "https://<TENANT-NAME>.sharepoint.com/sites/<YOUR-SITE>"
$allLists = m365 spo list list --webUrl "$siteURL" --output json | ConvertFrom-Json
$allLibs = $allLists | where {$_.BaseTemplate -eq 101}
$results = @()
$fields = @('FileLeafRef', 'FileSystemObjectType')

foreach ($lib in $allLibs) {
    $allRequiredFields = m365 spo field list --webUrl "$siteURL" --listId $lib.Id --query "[?Required == ``true``]" --output json | ConvertFrom-Json

    if($allRequiredFields.Length -eq 0){
        continue
    }

    [array]$allRequiredFieldsInternalName = $($allRequiredFields | select InternalName).InternalName

    ForEach ($field in $fields)
    {
        If (-not ($allRequiredFieldsInternalName -contains $field))
        {
            $allRequiredFieldsInternalName += $field
        }
    }

    $allItems = m365 spo listitem list --webUrl "$siteURL" --listId $lib.Id --fields $($allRequiredFieldsInternalName -join ",") --output json | ConvertFrom-Json
    $allItems = $allItems | where {$_.FileSystemObjectType -eq 0}

    foreach($item in $allItems){
        foreach($requiredfield in $allRequiredFields){
            if($requiredfield.InternalName -eq "FileLeafRef"){
                continue
            }

            if ($null -eq $item["$($requiredfield.InternalName)"]) {
                    $results += [pscustomobject]@{
                        FileName = $item.FileLeafRef
                        FieldName = $requiredfield.Title
                        ListOrLibrary = $lib.Title
                        FileLocation = $lib.RootFolder.ServerRelativeUrl
                    }
            }
        }
    }
}
$results
