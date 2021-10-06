# Source: https://pnp.github.io/script-samples/spo-copy-webparts-to-another-page/README.html?tabs=pnpps

$username = "user@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd

#Login to SharePoint Site
Function ConnectToSPSite() {
    try {
        $SourceSiteUrl = Read-Host "Please enter source Site URL"
        if ($SourceSiteUrl) {
            Write-Host "Connecting to Site :'$($SourceSiteUrl)'..." -ForegroundColor Yellow  
            Connect-PnPOnline -Url $SourceSiteUrl -Credentials $Creds
            Write-Host "Connection Successfull to site: '$($SourceSiteUrl)'" -ForegroundColor Green              
            GetWebparts
        }
        else {
            Write-Host "Source Site URL is empty" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error in connecting to Site:'$($SiteUrl)'" $_.Exception.Message -ForegroundColor Red               
    } 
}

Function GetWebparts {
    try {        
        $PageName = Read-Host "Please enter page name from where you want to copy webparts like 'Home.aspx'"
        if ($PageName) {
            Write-Host "Getting webparts from source page" -ForegroundColor Yellow  
            $page = Get-PnPClientSidePage -Identity $PageName          
            $webParts = $page.Controls  
            $WebpartsCount = $page.Controls.Count
            Write-Host "Found no. of webparts: " $WebpartsCount -ForegroundColor Gray  
            $DestinationPage = Read-Host "Please enter page name where you want to copy webparts like 'Home'"
            if ($WebpartsCount -gt 0) {
                Write-Host "Adding webparts to the page: " $DestinationPage -ForegroundColor Yellow  
                foreach ($wp in $webParts) {
                    try {                        
                        Add-PnPClientSideWebPart -Page $DestinationPage -Component $wp.Title -WebPartProperties $wp.PropertiesJson -Section $wp.Section.Order -Column $wp.Column.LayoutIndex -Order $wp.Order
                    }
                    catch {
                        Write-Host "Error in adding webparts'" $_.Exception.Message -ForegroundColor Red               
                    }
                }
                Write-Host "Added all the webparts" -ForegroundColor Green  
            }
            else {
                Write-Host "No webparts found'"-ForegroundColor Gray               
            }
        }
        else {
            Write-Host "Page name is empty" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error in getting webparts from:'$($PageName)'" $_.Exception.Message -ForegroundColor Red               
    } 
}

Function StartProcessing { 
    ConnectToSPSite 
}

StartProcessing

