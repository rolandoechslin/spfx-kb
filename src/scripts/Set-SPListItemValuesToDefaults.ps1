<#
.SYNOPSIS
Resets columns in a document library to defaults for blank columns. Use this
after changing the content types or adding columns to a doc lib with existing files

.DESCRIPTION
Resets columns in a doc lib to their defaults. Will only set them if the columns are blank (unless overridden)
Will also copy some values from one column to another while you are there.
Can restrict the update to a subset of columns, or have it look for all columns with defaults.
Will use the list defaults as well as folder defaults. 
All names of columns passed in should use InternalName.

This has ONLY been tested on Text, Choice, Metadata, and mult-Choice and Mult-Metadata columns

Pass in a list and it will recursively travel down the list to update all items with the defaults for the items in that folder.
If you call it on a folder, it will travel up the tree of folders to find the proper defaults
Author:
Chris Buchholz
chriswb71@gmail.com
@plutosdad

.PARAMETER list
The document library to update. Using this parameter it will update all files in the doc lib

.PARAMETER folder
The folder containing files to update. Function will update all files in this folder and subfolders.

.PARAMETER ParentFolderDefaults
Hashtable of internal field names as KEY, and value VALUE, summing up all the parent folders or list defaults.
If not supplied, then the function will travel up the tree of folders to the parent doclib to determine
the correct defaults to apply.
If the field is managed metadata, then the value is a string
Currently only tested for string and metadata values, not lookup or date

.PARAMETER termstore
The termstore to use if you are going to update managed metadata columns, this assumes we are only using the one termstore for all columns to update
If you are using the site collection specific termstore for some columns you want to update, and 
the central termstore for others, then you should call this method twice, once with each termstore,
and specify the respective columns in fieldsToUpdate

.PARAMETER fieldsToCopy
Hashtable of internal field names, where KEY is the "to" field, and VALUE is the "from" field
Use this to copy values from one field to another for the item.
These override the defaults, and also cause the "from" (Value) fields to NOT be overwritten with defaults even if
they are in the fieldsToUpdate array.
Example: @{"MyNewColumn" = "My_x0020_Old_x0020_Column"}

.PARAMETER fieldsToUpdate
If supplied then the method will update only the fields in this array to their default values, if null then it will update
all fields that have defaults.
If you pass in an empty array, then this method will only copy fields in the fieldtocopy and not
apply any defaults
Example: @() - to only copy and not set any fields to default
Example2: @('UpdateField1','UpdateField2') will 

.EXAMPLE
Set-SPListItemValuesToDefaults -list $list -fieldsToCopy @{"MyNewColumn" = "My_x0020_Old_x0020_Column"} -fieldsToUpdate @()   -overwrite -termStore $termStore
This will not set any defaults, but instead only set MyNewColumn to non null values of My_x0020_Old_x0020_Column
It will overwrite any values of MyNewColumn

.EXAMPLE 
Set-SPListItemValuesToDefaults -list $list -overwrite
This will set all columns to their default values even if they are filled in already

.EXAMPLE 
Set-SPListItemValuesToDefaults -folder $list.RootFolder.SubFolder[3].SubFolder[5]
This will set all columns to their defaults in the given subfolder of a library

.EXAMPLE 
Set-SPListItemValuesToDefaults -list $list -fieldsToUpdate @('ColumnOneInternalName','ColumnTwoInternalName')
This will set columns ColumnOneInternalName and ColumnTwoInternalName to their defaults for all items where they are currently null


.EXAMPLE
Set-SPListItemValuesToDefaults -list $list -fieldsToCopy @{"MyNewColumn" = "My_x0020_Old_x0020_Column"} -fieldsToUpdate @("MyNewColumn")   -termStore $termStore
This will set all MyNewColumn values to their default, and then also copy the values of My_x0020_Old_x0020_Column to MyNewColumn where the old column is not null,
but both of these will only happen  for items where MyNewColumn is null

.EXAMPLE
Set-SPListItemValuesToDefaults -list $list -fieldsToCopy @{"MyNewColumn" = "My_x0020_Old_x0020_Column"}  -termStore $termStore
This will set ALL columns with defaults to the default value (if the item's value is null), 
except for My_x0020_Old_x0020_Column which will not be modified even if it has a default value, and will also set MyNewColumn to the 
value of My_x0020_Old_x0020_Column if the old value is not null



#>
function Set-SPListItemValuesToDefaults {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName="List")][Microsoft.SharePoint.SPList]$list,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName="Folder")][Microsoft.SharePoint.SPFolder]$folder,
    [Parameter(Mandatory=$false,ParameterSetName="Folder")][HashTable]$ParentFolderDefaults,
    [Parameter(Mandatory=$false)][HashTable]$fieldsToCopy,
    [Parameter(Mandatory=$false)][Array]$fieldsToUpdate,
    [Parameter(Mandatory=$false)][Microsoft.SharePoint.Taxonomy.TermStore]$termStore,
    [Switch]$overwrite,
    [Switch]$overwriteFromFields
    ) 

    begin {
        #one or both can be null, but if both empty, then nothing to do
        if ($null -ne $fieldsToUpdate -and $fieldsToUpdate.Count -eq 0 -and
            ( $null -eq $fieldsToCopy  -or $fieldsToCopy.Count -eq 0)) {
            Write-Warning "No fields to update OR copy"
            return
        }
        if ($PSCmdlet.ParameterSetName -eq "Folder") {
            $list = $folder.DocumentLibrary
        }
        if ($null -eq $termStore  ) {
            $taxonomySession = Get-SPTaxonomySession  -site $list.ParentWeb.Site
            $termStores = $taxonomySession.TermStores
            $termStore = $termStores[0]
        }
        #if we did not pass in the parent folder defaults then we must go backward up tree
        if ($PSCmdlet.ParameterSetName -eq "Folder" -and $null -eq $ParentFolderDefaults ) {
            $ParentFolderDefaults = @{}
            if ($null -eq $fieldsToUpdate -or $fieldsToUpdate.Count -gt 0) {
                write-Debug "ParentFolderDefaults is null"
                $tempfolder=$folder.ParentFolder
                while ($tempfolder.ParentListId -ne [Guid]::Empty) {
                    Write-Debug "at folder $($tempfolder.Url)"
                    $pairs = $columnDefaults.GetDefaultMetadata($tempfolder)
                    foreach ($pair in $pairs) {
                        if (!$ParentFolderDefaults.ContainsKey($pair.First)) {
                            Write-Debug "Folder $($tempfolder.Name) default: $($pair.First) = $($pair.Second)"
                            $ParentFolderDefaults.Add($pair.First,$pair.Second)
                        }   
                    }
                    $tempfolder = $tempfolder.ParentFolder
                }
                #listdefaults
                Write-Debug "at list"
                foreach ($field in $folder.DocumentLibrary.Fields) {
                    if ($field.InternalName -eq "_ModerationStatus") { continue }
                    #$field = $list.Fields[$name]
                    if (![String]::IsNullOrEmpty($field.DefaultValue)) {
                        #Write-Verbose "List default found key $($field.InternalName)"
                        if (!$ParentFolderDefaults.ContainsKey($field.InternalName)) {
                            Write-Debug "List Default $($field.InternalName) = $($field.DefaultValue)"
                            $ParentFolderDefaults.Add($field.InternalName,$field.DefaultValue)
                        }
                    }
                }
            }
        }



    }

    process {
        Write-Debug "Calling with $($PSCmdlet.ParameterSetName)"
        Write-Debug "Parent folder hash has $($ParentFolderDefaults.Count) items"
        if ($PSCmdlet.ParameterSetName -eq "List" ) {
            $folder = $list.RootFolder
            $ParentFolderDefaults=@{}
            if ($null -eq $fieldsToUpdate -or $fieldsToUpdate.Count -gt 0) {
                foreach ($field in $list.Fields) {
                    if ($field.InternalName -eq "_ModerationStatus") { continue }
                    if (![String]::IsNullOrEmpty($field.DefaultValue)) {
                        Write-Debug "List Default $($field.InternalName) = $($field.DefaultValue)"
                        $ParentFolderDefaults.Add($field.InternalName,$field.DefaultValue)
                    }
                }
            }

        } 
  

        Write-Verbose "At folder $($folder.Url)"

        $FolderDefaults=@{}
        $FolderDefaults += $ParentFolderDefaults
        if ($null -eq $fieldsToUpdate -or $fieldsToUpdate.Count -gt 0) {
            $pairs = $columnDefaults.GetDefaultMetadata($folder)
            foreach ($pair in $pairs) {
                if ($FolderDefaults.ContainsKey($pair.First)) {
                    $FolderDefaults.Remove($pair.First)
                }
                Write-Debug "Folder $($folder.Name) default: $($pair.First) = $($pair.Second)"
                $FolderDefaults.Add($pair.First,$pair.Second)
            }
        }
        
        #set values
        foreach ($file in $folder.Files) {

            if ($file.CheckOutType -ne [Microsoft.SharePoint.SPFile+SPCheckOutType]::None) {
                Write-Warning "File $($file.Url).CheckOutType = $($file.CheckOutType)) ... skipping"
                continue
            }
            $item = $file.Item
            $ItemDefaults=@{}
            $ItemDefaults+= $FolderDefaults

            #if we only want certain fields then remove the others
            #Move this to every time we add values to the defaults
            if ($null -ne $fieldsToUpdate  ) {
                $ItemDefaults2=@{}
                foreach ($fieldInternalName in $fieldsToUpdate) {
                    try {
                        $ItemDefaults2.Add($fieldInternalName,$ItemDefaults[$fieldInternalName])
                    } catch { } #who cares if not in list
                }
                $ItemDefaults = $ItemDefaults2
            }
            #do not overwrite already filled in values unless specified
            if (!$overwrite) {
                $keys = $itemDefaults.Keys
                for ($i=$keys.Count - 1; $i -ge 0; $i-- ) {
                    $key=$keys[$i]
                    try {
                        $val =$item[$item.Fields.GetFieldByInternalName($key)]
                        if ($val -ne $null) {
                            $ItemDefaults.Remove($key)
                        }
                    } catch {} #if fieldname does not exist then ignore, we should check for this earlier
                }
            }
            #do not overwrite FROM fields in copy list unless specified
            if (!$overwriteFromFields) {
                if ($null -ne $fieldToCopy -and $fieldsToCopy.Count -gt 0) {
                    foreach ($value in $fieldsToCopy.Values) {
                        try {
                            $ItemDefaults.Remove($value)
                        } catch {} #who cares if not in list
                    }
                }
            }
            #do not overwrite TO fields in copy list if we're going to copy instead
            if (!$overwriteFromFields) {
                if ($null -ne $fieldToCopy -and $fieldsToCopy.Count -gt 0) {
                    foreach ($key in $fieldsToCopy.Keys) {
                        $fromfield = $item.Fields.GetFieldByInternalName($fieldsToCopy[$key])
                        try {
                            if ($null -ne $item[$fromfield]) {
                                $ItemDefaults.Remove($key)
                            }
                        } catch {} #who cares if not in list
                    }
                }
            }


            Write-Verbose $item.Url
            $namestr = [String]::Empty
            if ($ItemDefaults.Count -eq 0) {
                write-Verbose "No defaults, copy only"
            } else {
                $str = $ItemDefaults | Out-String
                $namestr += $str
                Write-Verbose $str
            }
            if ($null -ne $fieldsToCopy  -and $fieldsToCopy.Count -gt 0) {
                $str = $fieldsToCopy | Out-String
                $namestr +=$str
            }

            if ($PSCmdlet.ShouldProcess($item.Url,"Set Values: $namestr")) 
            {
                #defaults
                if ($null -ne $ItemDefaults -and $ItemDefaults.Count -gt 0) {
                    foreach ($key in $ItemDefaults.Keys) {
                        $tofield = $item.Fields.GetFieldByInternalName($key)
                        if ($tofield.TypeAsString -like "TaxonomyFieldType*") {
                            $taxfield =[Microsoft.SharePoint.Taxonomy.TaxonomyField]$tofield
                            $taxfieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($tofield)
                            $lookupval=$ItemDefaults[$key]
                            $termval=$lookupval.Substring( $lookupval.IndexOf('#')+1)
                            $taxfieldValue.PopulateFromLabelGuidPair($termval)
                            if ($tofield.TypeAsString -eq "TaxonomyFieldType") {
                               $taxfield.SetFieldValue($item,$taxfieldValue)
                            } else {
                                #multi
                                $taxfieldValues = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValueCollection $tofield 
                                $taxfieldValues.Add($taxfieldValue)
                                $taxfield.SetFieldValue($item,$taxfieldValues)
                            }
 
                        } else {
                           $item[$field]=$ItemDefaults[$key]
                        }
                    }
                }
                #copyfields
                if ($null -ne $fieldsToCopy -and $fieldsToCopy.Count -gt 0) {
                    #$fieldsToCopy | Out-String | Write-Verbose
                    foreach ($key in $fieldsToCopy.Keys) {
                        $tofield = $item.Fields.GetFieldByInternalName($key)
                        $fromfield = $item.Fields.GetFieldByInternalName($fieldsToCopy[$key])
                        if ($null -eq $item[$fromfield] -or ( !$overwrite -and $null -ne $item[$tofield] )) {
                            continue
                        }
                        if ($tofield.TypeAsString -eq "TaxonomyFieldType" -and 
                            $fromfield.TypeAsString -notlike "TaxonomyFieldType*" ) {
                            #non taxonomy to taxonomy
                            $taxfield =[Microsoft.SharePoint.Taxonomy.TaxonomyField]$tofield
                            $termSet = $termStore.GetTermSet($taxfield.TermSetId)

                            [String]$fromval = $item[$fromfield]
                            $vals = $fromval -split ';#' | where {![String]::IsNullOrEmpty($_)}
                            if ($null -ne $vals -and $vals.Count -ge 0 ) {
                                $val = $vals[0]
                                if ($vals.Count -gt 1) {
                                    write-Warning "$($item.Url) Found more than one value in $($fromfield.InternalName)"
                                    continue
                                }
                                $terms =$termSet.GetTerms($val,$true)
                                if ($null -ne $terms -and $terms.Count -gt 0) {
                                   $term = $terms[0]
                                   $taxfield.SetFieldValue($item,$term)
                                   Write-Verbose "$($tofield.InternalName) = $($term.Name)"
                                }
                            } else {
                                Write-Warning "Could not determine term for $($fromfield.InternalName) for  $($item.Url)"
                                continue
                            }

                        } elseif ($tofield.TypeAsString -eq "TaxonomyFieldTypeMulti" -and 
                            $fromfield.TypeAsString -notlike "TaxonomyFieldType*" ) {
                            Write-Debug "we are here: $($item.Name):  $($fromfield.TypeAsString) to $($tofield.TypeAsString )"
                            #non taxonomy to taxonomy

                            $taxfield =[Microsoft.SharePoint.Taxonomy.TaxonomyField]$tofield
                            $termSet = $termStore.GetTermSet($taxfield.TermSetId)
                            $taxfieldValues = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValueCollection $tofield 

                            [String]$fromval = $item[$fromfield]
                            $vals = $fromval -split ';#' | where {![String]::IsNullOrEmpty($_)}

                            foreach ($val in $vals){
                                $terms =$termSet.GetTerms($val,$true)
                                if ($null -ne $terms -and $terms.Count -gt 0) {
                                    $term=$terms[0]
                                    $taxfieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($tofield)
                                    $taxfieldValue.TermGuid = $term.Id.ToString()
                                    $taxfieldValue.Label = $term.Name
                                    $taxfieldValues.Add($taxfieldValue)
                                } else {
                                    Write-Warning "Could not determine term for $($fromfield.InternalName) for  $($item.Url)"
                                    continue
                                }
                                #,[Microsoft.SharePoint.Taxonomy.StringMatchOption]::ExactMatch,
                            }
                            $taxfield.SetFieldValue($item,$taxfieldValues)
                            $valsAsString = $taxfieldValues | Out-String
                            Write-Debug "$($tofield.InternalName) = $valsAsString" 
                            
                        } elseif ($tofield.TypeAsString -eq "TaxonomyFieldTypeMulti" -and 
                            $fromfield.TypeAsString -eq "TaxonomyFieldType" ) {
                            #single taxonomy to multi
                            $taxfieldValues = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValueCollection $tofield 
                            $taxfield =[Microsoft.SharePoint.Taxonomy.TaxonomyField]$tofield
                            $taxfieldValues.Add($item[$fromfield])
                            $taxfield.SetFieldValue($item,$taxFieldValues)
                            Write-Verbose "$($tofield.InternalName) = $valsAsString"
                        } elseif ($tofield.TypeAsString -eq "TaxonomyFieldType" -and 
                            $fromfield.TypeAsString -eq "TaxonomyFieldTypeMulti" ) {
                            #multi taxonomy to single taxonomy
                            Write-Warning "multi to non multi - what to do here"
                            continue
                        } elseif ($tofield.TypeAsString -eq "Lookup" -and 
                            $fromfield.TypeAsString -ne "Lookup" ) {
                            #non lookup to lookup
                            Write-Warning "non lookup to lookup - still todo"
                            continue
                        } else {
                            #straight copy
                            $item[$tofield] =  $item[$fromfield] 
                        }
                    }
                }
                $item.SystemUpdate($false)
            }
                
            
        }
        $folders = $folder.SubFolders | where name -ne "Forms"
        $folders | Set-SPListItemValuesToDefaults -ParentFolderDefaults $FolderDefaults  -fieldsToCopy $fieldsToCopy -fieldsToUpdate $fieldsToUpdate -overwrite:$overwrite -overwriteFromFields:$overwriteFromFields -termStore $termStore
    }
}