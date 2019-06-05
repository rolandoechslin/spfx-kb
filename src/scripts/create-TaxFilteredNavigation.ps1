#############################################
# Author: Piyush K Singh
# Email: piyushksingh11@gmail.com
# Website: https://piyushksingh.com/2019/05/24/generate-modern-list-filter-url-managed-metadata/
# Version: 1.0
#############################################

Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"

#GLOBAL Objects
$global = @{}

$file
$fieldCollection = New-Object 'System.Collections.Generic.Dictionary[String, Microsoft.SharePoint.Client.Taxonomy.TaxonomyField]'
$completedNavs = @{}

function GetTermStore 
{
    <#
    # Gets the specific Term from a given TermSet

    # .Parameter $termSetName
    # The name of the TermSet

    # .Parameter $termName
    # Name of the Term

    #>
    Param(
        [Parameter(Mandatory)][string] $termSetName,
        [Parameter(Mandatory)][string] $termName
    )


    if($global.groupReports -eq $null)
    {
        $session = $spTaxSession = [Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($global.context)
        $session.UpdateCache();
        $global.context.Load($session)

        $termStores = $session.TermStores
        $global.context.Load($termStores)
        $global.context.ExecuteQuery()

        $termStore = $TermStores[0]
        $global.context.Load($termStore)

        $groups = $termStore.Groups
        $global.context.Load($groups)

        #Loading the Term Group from the config file
        $global.groupReports = $groups.GetByName($file.grpName)
        $global.context.Load($global.groupReports)
    }

    $termSetField = $global.groupReports.TermSets.GetByName($termSetName)

    $global.context.Load($termSetField)

    $terms = $termSetField.Terms.GetByName($termName)
    $global.context.Load($terms)
    $global.context.ExecuteQuery()

    return $terms
}

function GetList
{
    <#
    # Gets the list/library based on the name provided in the config file

    #>

    $lists = $global.context.web.Lists
    $global.context.Load($lists)
    $list = $lists.GetByTitle($file.listName) #Name
    $global.context.ExecuteQuery()

    $global.list = $list
}

function GetField
{
    <#
    # Gets the SharePoint Field for which the filter URL needs to be generated

    # .Parameter $fieldName
    # The name of the field. InternalName

    #>

    Param(
        $fieldName
    )

    if(!$fieldCollection.ContainsKey($fieldName))
    {
        $field = $global.list.Fields.GetByInternalNameOrTitle($fieldName)
        $global.context.ExecuteQuery()

        #Create a cache of field so as to not fetch the same field again and again
        $fieldCollection.Add($fieldName, [Microsoft.SharePoint.Client.ClientContext].GetMethod("CastTo").MakeGenericMethod([Microsoft.SharePoint.Client.Taxonomy.TaxonomyField]).Invoke($global.context, $field))
    }

    #returns the cached value
    return $fieldCollection[$fieldName]
}

function GetListItem
{
    <#
    # Gets a fixed listitem onetime to constantly update its property in order to generate the unique WSSID

    # .Parameter $isForce
    # Forces the application to fetch an item

    #>

    Param(
        [boolean] $isForce
    )

    if($isForce -or ($global.listItem -eq $null))
    {
        $listItem = $global.list.GetItemById($file.listItemId)
        $global.context.Load($listItem)
        $global.context.ExecuteQuery()

        $global.listItem = $listItem
    }
}

function GetTermFieldValue
{
    <#
    # Gets the TaxonomyFieldValue to update the list item

    # .Parameter $termSetName
    # Name of the TermSet

    # .Parameter $termName
    # Name of the Term

    #>

    Param(
        [Parameter(Mandatory)][string] $termSetName,
        [Parameter(Mandatory)][string] $termName
    )

    $term = GetTermStore $termSetName $termName

    $txField1value = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValue 
    $txField1value.Label = $term.Name           # the label of your term 
    $txField1value.TermGuid = $term.Id          # the guid of your term 
    $txField1value.WssId = -1 

    return $txField1value
}

function IntializeContext
{
    <#
    # Initializes the global client context 

    # .Parameter $userName
    # UserName to connect to SharePoint

    # .Parameter $pwd
    # Password to connect to SharePoint

    # .Parameter $siteUrl
    # Site URL where this operation is to be conducted

    #>

    Param(
        [Parameter(mandatory=$true)] $userName,
        [Parameter(mandatory=$true)] $pwd,
        [Parameter(mandatory=$true)] $siteUrl
    )

    $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName,$pwd)
    
    #Setup the context
    $context = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
    $context.Credentials = $credentials

    $global.context = $context

}

function UpdateListItem
{
    <#
    # Updates the given listItem with a term value to generate its unique WssId

    # .Parameter $fieldName 
    # The name of the field to be updated

    # .Parameter $termsetName
    # The name of the TermSet

    # .Parameter $columnValue
    # TaxonomyFieldValue to be updated

    #>

    Param (
        [Parameter(mandatory=$true)] $fieldName,
        [Parameter(mandatory=$true)] $termsetName,
        [Parameter(mandatory=$true)] $columnValue
    )

    $field = GetField $fieldName
    $termFieldValue = GetTermFieldValue $termsetName $columnValue
    $field.SetFieldValueByValue($global.listItem, $termFieldValue)

    $global.listItem.Update()
    $global.context.ExecuteQuery()
}

function GetWssId
{
    <# 
    # Gets the unique WssId for a given TermSet

    # .Parameter $fieldName
    # The fieldName from which the value is to be extracted

    #>

    Param (
        [Parameter(mandatory=$true)]
        [string] 
        $fieldName
    )

    return $global.listItem[$fieldName].WssId
}

function ContructNavUrl
{
    <#
    # Contructs the dynamic NAV URL to be used to directly navigate to the filtered view

    # .Parameter $wssId
    # The unique WssId of a Term

    # .Parameter $fieldName
    # The name of the field being used

    #>

    Param (
        [Parameter(mandatory=$true)]
        [string] 
        $wssId,

        [Parameter(mandatory=$true)]
        [string] 
        $fieldName
    )

    #/teams/SiteName/Published/Forms/AllItems.aspx?useFiltersInViewXml=1&FilterField1=Process&FilterValue1=28&FilterType1=Counter&FilterLookupId1=1&FilterOp1=In
    return "{0}?useFiltersInViewXml=1&FilterField1={1}&FilterValue1={2}&FilterType1=Counter&FilterLookupId1=1&FilterOp1=In" -f $file.serverRelativeURL,$fieldName,$wssId
}

function AddNavigation
{
    <#
    # Adds a Navigation to the SharePoint site

    # .Parameter $title
    # Nav title

    # .Parameter $wssId
    # Unique WssId

    # .Parameter $fieldInternalName
    # The internal name of the field

    # .Parameter $header
    # If it's a child NAV then, provide a header/parent

    # .Parameter $isConnect
    # If connect to PnP is required or not. Required only first time

    #>

    Param (
        [Parameter(mandatory=$true)]
        [string] 
        $title,

        [Parameter(mandatory=$true)]
        [string] 
        $wssId,

        [Parameter(mandatory=$true)]
        [string] 
        $fieldInternalName,

        [string]
        $header,

        [boolean]
        $isConnect
    )

    if($isConnect)
    {
        ConnectToPnpOnline   
    }

    if(AllowNavCreation $title $header)
    {
        $urlNav = ContructNavUrl $wssId $fieldInternalName

        Add-PnPNavigationNode -Title $title  -Url $urlNav -Location "QuickLaunch" -Header $header -External

        Write-Log -message ("Adding: $title") -logEntryType Information
    }

}

function ConnectToPnpOnline
{ 
    <#
    # Connects to PnPOnline in order to create the NAV. Reusing the credential from the context to avoid prompting the same again

    #>

    $userCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $file.userName, $file.$pwd
    Connect-PnPOnline -Url $global.context.Url -Credentials $userCredential 
}

function GetStringListCollection
{
    <# 
    # Initializes a new List collection to cache the already created NAV. This will prevent any duplicate creation of the same NAV

    #>

    return New-Object System.Collections.Generic.List[string]
}

function AllowNavCreation
{
    <#
    # Creates the global navigation. Checks if its a parent or child and then create the nav accordingly. Also checks if a global NAV has 
    # already been created by this script. In that case, it blocks any duplicate creation of the same NAV

    # .Parameter $childNav 
    # The new NAV to be created

    # .Parameter $headerNav
    # Header NAV for if the new NAV is a child

    #>

    Param(
        [Parameter(mandatory=$true)]
        [string]        
        $childNav,

        [string]        
        $headerNav
    )

    $isAllowed = $true

    $isHeaderBlank = $headerNav.Length -eq 0
    $currentNav = if($isHeaderBlank) { $childNav } else { $headerNav }

    if(!$completedNavs.ContainsKey($currentNav))
    {
        $completedNavs.Add($currentNav, (GetStringListCollection))
    } 
    elseif(!$isHeaderBlank -and !$completedNavs[$currentNav].Contains($childNav))
    {
        $completedNavs[$currentNav].Add($childNav)
    }
    else
    {
        $isAllowed = $false
        Write-Log -message ("Already exist: $childNav") -logEntryType Warning
    }

    return $isAllowed
}

function GetFieldInternalName 
{
    <# Returns the internal name of a field from the list

    # .Parameter $columnName
    # Name of the column

    #>

    Param(
        [Parameter(mandatory=$true)] $columnName
    )

    if($file.fields[$columnName].Length -gt 0) { return $file.fields[$columnName] } else { return $columnName }
}

function ParseCSV
{
    <# Parses the input CSV file for the NAV data

    # .Parameter $csvFilePath
    # Path of the CSV file

    #>

    Param (
        [Parameter(mandatory=$true)] $csvFilePath
    )

    $csvFileContent = Import-Csv -Path $csvFilePath
    $csvLength = $csvFileContent.Count
    
    #Split the header name if it contains 2 or more spaces
    $csvHeaders = (($csvFileContent[0] | out-string) -split '\n')[1] -split '\s \s+'

    $i = -1
    $isContinue = $true
    $connectPnp = $true

    while ($isContinue)
    {
        $i++

        if($i -ge $csvLength) 
        { 
            $isContinue = $false 
            continue
        }

        $previousLink = $null

        $csvHeaders | ForEach {
            if($_.Length -eq 0)
            {
                continue
            }


            $fieldInternalName = GetFieldInternalName $_
            $cellValue = $csvFileContent[$i].$_

            GetListItem
            UpdateListItem $fieldInternalName $_ $cellValue
            
            GetListItem $true
            AddNavigation $cellValue (GetWssId $fieldInternalName) $fieldInternalName $previousLink $connectPnp

            $previousLink = $cellValue
            $connectPnp = $false
        }

    }

}

function InitiateNavCreation
{
    <#
    # Main method

    # .Parameter $configFilePath
    Configuration file path

    #>

    Param (
        [string] $configFilePath = "E:\Piyush\Scripts\CreateFilterUrlInNavigation.psd1"
    )    

    $file = Import-LocalizedData -FileName "CreateFilterUrlInNavigation.psd1"
     
    $file.$pwd = $( Read-host -assecurestring "Enter Password for " $file.userName )

    IntializeContext $file.userName $file.$pwd $file.siteUrl

    GetList $file.listName

    ParseCSV $file.csvFilePath

}

function ClearObjects
{
    <#
    # Release memory from global objects. Close the session

    #>

    $global.context.Dispose()
    
    $global.Clear()
    $fieldCollection.Clear()
    $completedNavs.Clear()    

    Disconnect-PnPOnline
}

function PrepareLogFile
{
    <#
    # Prepares the log file
    #>

    $strartTimestamp = GetTimeStamp
    $directoryPath = GetCurrentDirectory

    $fileName = "\NavURLLog_" + $strartTimestamp + ".txt"

    $createEnv = @"
=================================================
|Script Started By   : $ENV:USERNAME
|Script Start Time   : $strartTimestamp
|Computer Name       : $Env:Computername
=================================================
"@

    $global.filePath = ($directoryPath + $fileName)

    try
    {
        New-Item -ItemType File -Path $global.filePath
    }
    catch
    {
        return $false
    }

    if($?)
    {
        Add-Content -Value $createEnv -Path $global.filePath
    }
}

function Write-Log
{
    Param(
        [Parameter(Mandatory=$true)][String]$message,
        [Parameter(Mandatory = $true)][ValidateSet("Information","Warning","Error")][String]$logEntryType,
        [Bool]$printOnScreen = $true
    )

    $timeStamp = GetTimeStamp
    $fullMsg = $timeStamp + ": " + $logEntryType + ": " + $message
    
    switch($logEntryType)
    {
        "Information"
        {
            If($printOnScreen)
            {
                Write-Host $fullMsg -ForegroundColor Green
            }
            
            break          
        }

        "Warning"
        {
            If($printOnScreen)
            {
                Write-Host $fullMsg -ForegroundColor Yellow
            }
            
            break         
        }

        "Error"
        {
            If($printOnScreen)
            {
                Write-Host $fullMsg -ForegroundColor Red
            }
            
            break         
        }
    }

    Add-Content -Value $fullMsg -Path $global.filePath
}

function CompleteLog
{
    Add-Content -Value "*************************************************" -Path $global.filePath
}

function GetTimeStamp
{
    return ([String](Get-Date (Get-Date).ToUniversalTime() -Format "dd-MM-yyyy-HH-mm-ss"))
}

function GetCurrentDirectory
{
    if ($psISE)
    {
        return Split-Path -Path $psISE.CurrentFile.FullPath        
    }
    else
    {
        return $global:PSScriptRoot
    }
}


try
{
    PrepareLogFile
    InitiateNavCreation
}
catch
{
    Write-Log -message $_.Exception.Message -logEntryType Error
    Write-Log -message $_.Exception.ItemName -logEntryType Error
    Write-Log -message $_.Exception.StackTrace -logEntryType Error
}
finally
{
    CompleteLog
    
    ClearObjects
}
