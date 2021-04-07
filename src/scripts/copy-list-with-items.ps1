# source: https://techcommunity.microsoft.com/t5/microsoft-365-pnp-blog/copy-a-list-with-list-items-to-another-site/ba-p/2248892

Install-Module -Name PnP.PowerShell

# Step 1 - Connect to the Source Site
Connect-PnPOnline -Url https://constoso.sharepoint.com/sites/star-wars -Interactive

# Step 2 - Create the Template
Get-PnPSiteTemplate -Out Lists.xml -ListsToExtract "Middle Earth Locales", "Fellowship Members" -Handlers Lists

# Step 3 - Get the List Data
Add-PnPDataRowsToSiteTemplate -Path Lists.xml -List "Middle Earth Locales"
Add-PnPDataRowsToSiteTemplate -Path Lists.xml -List "Fellowship Members"

# Step 4 - Connect to Target Site
Connect-PnPOnline -Url https://constoso.sharepoint.com/sites/lotr -Interactive

# Step 5 - Apply the Template
Invoke-PnPSiteTemplate -Path Lists.xml