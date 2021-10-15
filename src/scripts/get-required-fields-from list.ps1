
# https://pnp.github.io/script-samples/spo-get-and-export-list-fields/README.html?tabs=pnpps

$username = "chandani@domain.onmicrosoft.com"
$password = "*******"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$global:listFields = @()
$BasePath = "E:\Contribution\PnP-Scripts\ListFields\"
$DateTime = "{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$CSVPath = $BasePath + "\listfields" + $DateTime + ".csv"

Function ConnectToSPSite() {
    try {
        $SiteUrl = Read-Host "Please enter Site URL"
        if ($SiteUrl) {
            Write-Host "Connecting to Site :'$($SiteUrl)'..." -ForegroundColor Yellow  
            Connect-PnPOnline -Url $SiteUrl -Credentials $Creds
            Write-Host "Connection Successfull to site: '$($SiteUrl)'" -ForegroundColor Green              
            GetListFields
        }
        else {
            Write-Host "Source Site URL is empty." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error in connecting to Site:'$($SiteUrl)'" $_.Exception.Message -ForegroundColor Red               
    } 
}

Function GetListFields() {
    try {
        $ListName =  Read-Host "Please enter list name"
        if ($ListName) {
            Write-Host "Getting fields from :'$($ListName)'..." -ForegroundColor Yellow  
            $ListFields = Get-PnPField -List $ListName
            Write-Host "Getting fields from :'$($ListName)' Successfully!" -ForegroundColor Green  
            foreach ($ListField in $ListFields) {  
                $global:listFields += New-Object PSObject -Property ([ordered]@{
                        "Title"            = $ListField.Title                           
                        "Type"             = $ListField.TypeAsString                         
                        "Internal Name"    = $ListField.InternalName  
                        "Static Name"      = $ListField.StaticName  
                        "Scope"            = $ListField.Scope  
                        "Type DisplayName" = $ListField.TypeDisplayName                          
                        "Is read only?"    = $ListField.ReadOnlyField  
                        "Unique?"          = $ListField.EnforceUniqueValues  
                        "IsRequired"       = $ListField.Required
                        "IsSortable"       = $ListField.Sortable
                        "Schema XML"       = $ListField.SchemaXml
                        "Description"      = $ListField.Description 
                        "Group Name"       = $ListField.Group   
                    })
            }  
        }
        else {
            Write-Host "List name is empty." -ForegroundColor Red
        }
        BindingtoCSV($global:listFields)
        $global:listFields = @()
    }
    catch {
        Write-Host "Error in getting list fields from :'$($ListName)'" $_.Exception.Message -ForegroundColor Red               
    } 
    Write-Host "Export to CSV Successfully!" -ForegroundColor Green
}

Function BindingtoCSV {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Global)       
    $global:listFields | Export-Csv $CSVPath -NoTypeInformation -Append            
}

ConnectToSPSite

