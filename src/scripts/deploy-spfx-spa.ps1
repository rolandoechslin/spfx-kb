# Source: https://ypcode.wordpress.com/2019/09/23/deploy-corporate-spfx-app-pages/

param(
    [Parameter(Mandatory = $true)]
    [string]$web,
    [Parameter(Mandatory = $true)]
    [string]$pageName,
    [Parameter(Mandatory = $true)]
    [string]$appName,
    $appConfig,
    $pnpCredentials
)

Write-Host "Ensure connection to SharePoint site..." -ForegroundColor Yellow
try {
    $ctx = Get-PnPContext -ErrorAction Ignore
    If ($null -eq $ctx) {
        If ($null -eq $pnpCredentials) {
            Connect-PnPOnline $web
        }
        Else {
            Connect-PnPOnline $web -Credentials $pnpCredentials
        }
    }
    Write-Host "Connected to SharePoint site." -ForegroundColor Green
}
catch {
    throw "Cannot connect to SharePoint site $web..."
}


# Ensure page name ends with .aspx
if (!$pageName.EndsWith(".aspx")) {
    $pageName = $("$pageName.aspx")
}

try {
    # Check if the page already exists
    Write-Host "Checking if $pageName already exists..." -ForegroundColor Yellow
    $page = Get-PnPClientSidePage -Identity $pageName -ErrorAction Ignore
    If ($null -eq $page) {
        # If the page does not exist, create it
        Write-Host "Creating page $pageName..." -ForegroundColor Cyan
        $page = Add-PnPClientSidePage -Name $pageName
        Write-Host "Page $pageName has been successfully created." -ForegroundColor Green
    }
    Else {
        Write-Host "Page $pageName does exist." -ForegroundColor Green
    }
}
catch {
    throw "Page cannot be found and could not be created."
}


# Try to get the component from available components
$appComponent = Get-PnPAvailableClientSideComponents -Page $page -Component $appName
If ($null -eq $appComponent) {
    Throw "The component $appName could not be found in the tenant. Please install it first"
}

# Ensure the app configuration if not specified
if ($null -eq $appConfig) {
    $appConfig = @{ };
}

try {
    Write-Host "Adding client side component $appName to page..." -ForegroundColor Yellow
    # Add the component (WebPart) to the page
    Add-PnPClientSideWebPart -Page $page -Component $appComponent -WebPartProperties $appConfig -OutVariable $addWpOut
    Write-Host "Client side component successfully added." -ForegroundColor Green
}
catch {
    throw "Client side component could not be added to page..."
}


try {
    Write-Host "Removing Edit permissions from application page for members..." -ForegroundColor Yellow
    # Set the edit permissions for the app page only for owners (Set read only for members)
    $members = Get-PnPGroup -AssociatedMemberGroup
    $appPageListItem = Get-PnPListItem -List "Site Pages"  -Query "<View><Query><Where><Eq><FieldRef Name='FileLeafRef'/><Value Type='Text'>$pageName</Value></Eq></Where></Query></View>"
    Set-PnPListItemPermission -List "Site Pages" -Identity $appPageListItem.Id -Group $members -RemoveRole Edit -AddRole Read -OutVariable $setPageOut
    Write-Host "Permissions successfully applied to application page" -ForegroundColor Green
}
catch {
    throw "Cannot change permissions for application page..."
}

try {
    Write-Host "Changing page layout type to single WebPart app page and publishing..." -ForegroundColor Yellow
    # Publish the page and change the layout to Single WebPart App page
    Set-PnPClientSidePage -Identity $page -LayoutType SingleWebPartAppPage -Publish -OutVariable $publishedOut
    Write-Host "Layout successfully changed and page successfully published" -ForegroundColor Green
}
catch {
    throw "The application page could not be published..."
}

Write-Host "Corporate single page application has been deployed to $web" -ForegroundColor Green
