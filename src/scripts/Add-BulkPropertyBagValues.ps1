# Source: 
# https://github.com/brenle/MIGScripts/tree/main/SPO-OD/AdaptiveScopes-PropertyBag
# https://brenle.github.io/MIGScripts/spo-od/adaptive-scopes-propertybag-scripts/

param (
    [Parameter(Mandatory = $true)][string]$customKeyToAdd,
    [Parameter(Mandatory = $true)][string]$csvFile,
    [Parameter(Mandatory = $true)][string]$storedCredential, # must first setup - https://pnp.github.io/powershell/articles/authentication.html#authenticating-with-pre-stored-credentials-using-the-windows-credential-manager-windows-only
    [switch]$overwrite = $false # enable if want to overwrite any existing prop bag values with same key
)

#static variables
$failedSites = 0
$completedSites = 0
$skippedSites = 0
$totalSites = 0
$pnpStillUnlocked = @{}

#verify the CSV provided is valid, then create a log file in the same location
function verifyCsvLocation([string]$csvFilePath)
{
    $tempFilepath = $csvFilePath.ToLower()
    if($tempFilepath.EndsWith(".csv"))
    {
        $pathExists = Test-Path($csvFilePath)
        if ($pathExists)
        {   
            $path = $csvFilePath | Split-Path
            $datetime = Get-Date -Format FileDateTime
            $logFile = $path + "\Add-BulkPropertyBagValuesLog-$datetime.csv"
            try {
                Add-Content -Path $logFile -Value '"DateTime","Url","Succeeded","FailureReason"' -ErrorAction stop
            } catch {
                Write-Host -ForegroundColor Red "Could not create log file"
                write-Host -ForegroundColor Red "Error: $($error[0].exception.message)"
                exit
            }
            return $logFile
        }
    } else {
        Write-Host -ForegroundColor Red "CsvFile string should end in .csv"
        exit
    }
}

#verify pnp online is installed, then verify credential was stored correctly
function verifyModule([string]$cred){

    #first verify pnp is installed
    try{
        $pnpModule = Get-Command Connect-PnPOnline -ErrorAction Stop | Out-Null

        #verify we are at least at version 1.9
        $installedModule = Get-Module PnP.PowerShell -ErrorAction Stop
        if($installedModule){
            if(!($installedModule.Version.Major -ge 1 -and $installedModule.Version.Minor -ge 9)){
                write-Host -ForegroundColor Red "You need to have at least PnP.PowerShell version 1.9 installed."
                Write-Host -ForegroundColor Red "You have version $($installedModule.Version.Major).$($installedModule.Version.Minor)."
                Write-Host -ForegroundColor Red "Run: Update-Module PnP.PowerShell -Force"
            }
        } else {
            Write-Host -ForegroundColor Red "There was an error verifying the installed version of PnP.PowerShell."
            Write-host -ForegroundColor Red "Try running: Import-Module PnP.PowerShell"
        }
    } catch {
        write-host -ForegroundColor Red "PnP Online module not installed."
        exit
    }

    #then verify credential was specified correctly in switch
    $checkIfCredIsStored = Get-PnPStoredCredential -Name $cred
    if(!$checkIfCredIsStored){
        write-host -ForegroundColor red "Credential was not stored.  Store credential using Add-PnPStoredCredential"
        exit
    }
    
}

function logWrite([string]$url, [bool]$result, [string]$reason, $log)
{
    Add-Content -Path $log -Value "$(Get-Date),$url,$result,$reason"
}

#initialization
$LogCsv = verifyCsvLocation $csvFile
verifyModule $storedCredential

#import CSV
try{
    $sites = Import-Csv $csvFile
} catch {
    Write-Host -ForegroundColor Red "Could not import sites from $csvFile"
    write-Host -ForegroundColor Red "Error: $($error[0].exception.message)"
    exit
}

#determine totalSites for progress bar/log
$totalSites = $sites.count
$i = 0

#will cycle through each site in the imported csv and attempt to set the new key value pair
foreach ($site in $sites){
    $keyValue = $site.$customKeyToAdd #value to add
    $i++

    Write-Progress -Activity "Processing site $i : $($site.Url)" -Status "Total Sites: $totalSites; Completed: $completedSites; Failed: $failedSites; Skipped: $skippedSites" -PercentComplete (($i/$totalSites)*100)
    
    #Connect to PnP Online. If failure, note as such.
    if($keyValue -ne ""){
        try {
            Connect-PnPOnline -Url $site.Url -Credentials $storedCredential -ErrorAction Stop  
        } catch {
            logWrite $site.url $false "Could not connect using PnP.  Incorrect stored credential or possibly a site collection permissions issue.  Error: $($error[0].exception.message)" $logCsv
            $failedSites++
            continue
        }

        #if no failures connecting, capture current property bag to verify if key already exists
        $propertyBag = Get-PnPPropertyBag -key $customKeyToAdd
        if (($propertyBag -eq "") -or ($overwrite -eq $true)){
            # key doesn't exist OR we allow overwrite
            # property bag is unlocked
            try {
                # set key:value pair
                Set-PnPAdaptiveScopeProperty -Key $customKeyToAdd -Value $keyValue -ErrorAction Stop
            } catch {
                # failed adding key:value pair
                logWrite $site.url $false "Could not write the key:value pair: $customKeyToAdd : $keyValue. Error: $($error[0].exception.message)" $logCsv
                $failedSites++
                continue
            }
        } else {
            # key already exists - overwrite disabled
            logWrite $site.url $false "A key:value pair already exists and overwrite is disabled: $customKeyToAdd : $($site.$customKeyToAdd)" $logCsv
            $failedSites++
            continue
        }
        Disconnect-PnPOnline
    } else {
        #skip site if no value is specified in csv (empty cell)
        logWrite $site.Url $false "NOTE: Skipped because no value was specified for this site in the CSV" $logCsv
        $skippedSites++
        continue
    }
    #if not skipped & success still = true, then note as success in log
    logWrite $site.url $true "" $logCsv
    $completedSites++
}

#output info
write-Host "Total Sites: $totalSites"
write-Host "Completed Sites: $completedSites"
Write-host "Failed Sites: $failedSites"
Write-Host "Skipped Sites: $skippedSites"

#note that there were failures or skipped sites
if(($failedSites -gt 0) -and ($failedSites -ne $skippedSites)){
    Write-Host -ForegroundColor Red "There were failures and/or skipped sites.  Check $logCsv for more info."
} elseif (($failedSites -eq 0) -and ($skippedSite -gt 0)){
    Write-Host -ForegroundColor Yellow "There were skipped sites.  Check $logCsv for more info."
}

