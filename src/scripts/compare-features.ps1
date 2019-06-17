#Source: http://www.sharepointdiary.com/2018/09/sharepoint-online-compare-features-between-sites-using-powershell.html#ixzz5r4ZcCHbP

#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
 
Function Compare-SPOFeatures
{
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$True)][URI]$SourceSiteURL,
        [Parameter(Mandatory=$True)][URI]$TargetSiteURL,
        [Parameter(Mandatory=$True)][ValidateSet('Site','Web')][String]$Scope
    )
 
    #Get Credentials to connect
    $Cred = Get-Credential
 
    #Get Source and Target Site Contexts
    $SourceCtx = New-Object Microsoft.SharePoint.Client.ClientContext($SourceSiteURL.AbsoluteUri)
    $SourceCtx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.UserName,$Cred.Password)
    $TargetCtx = New-Object Microsoft.SharePoint.Client.ClientContext($TargetSiteURL.AbsoluteUri)
    $TargetCtx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.UserName,$Cred.Password)
     
    #Get Features based on Given Scope
    Switch($Scope)
    {
        Site
        {
            Write-Host -f Yellow "Comparing Features Between Site Collections..."
            $SourceFeatures = $SourceCtx.Site.Features
            $TargetFeatures = $TargetCtx.Site.Features
            $SourceCtx.Load($SourceFeatures)
            $TargetCtx.Load($TargetFeatures)
            $SourceCtx.ExecuteQuery()
            $TargetCtx.ExecuteQuery()
        }
        Web
        {
            Write-Host -f Yellow "Comparing Features Between Sites..."
            $SourceFeatures = $SourceCtx.Web.Features
            $TargetFeatures = $TargetCtx.Web.Features
            $SourceCtx.Load($SourceFeatures)
            $TargetCtx.Load($TargetFeatures)
            $SourceCtx.ExecuteQuery()
            $TargetCtx.ExecuteQuery()
        }
    }
 
    $MismatchedFeatures = New-Object System.Collections.Arraylist
    ForEach($Feature in $SourceFeatures)
    {
        $Feature.Retrieve("DisplayName")
        $SourceCtx.Load($Feature)
        $SourceCtx.ExecuteQuery()
 
        If(!($TargetFeatures.DefinitionId -Match $Feature.DefinitionId))
        {
           $FeatureEntry = New-Object System.Object
           $FeatureEntry | Add-Member -MemberType NoteProperty -Name "Feature Name" -Value $Feature.DisplayName
           $FeatureEntry | Add-Member -MemberType NoteProperty -Name "Feature ID" -Value $Feature.DefinitionID
           $FeatureEntry | Add-Member -MemberType NoteProperty -Name "Activated In" -Value "Source Only"
           $MismatchedFeatures.Add($FeatureEntry) | Out-Null
        }
    }
    ForEach($Feature in $TargetFeatures)
    {
        $Feature.Retrieve("DisplayName")
        $TargetCtx.Load($Feature)
        $TargetCtx.ExecuteQuery()
 
        If(!($SourceFeatures.DefinitionId -Match $Feature.DefinitionId))
        {
           $FeatureEntry = New-Object System.Object
           $FeatureEntry | Add-Member -MemberType NoteProperty -Name "Feature Name" -Value $Feature.DisplayName
           $FeatureEntry | Add-Member -MemberType NoteProperty -Name "Feature ID" -Value $Feature.DefinitionID
           $FeatureEntry | Add-Member -MemberType NoteProperty -Name "Activated In" -Value "Target Only"
           $MismatchedFeatures.Add($FeatureEntry) | Out-Null
        }
    }
    Return $MismatchedFeatures
}
 
#Call the Function to compare features between site collections
Compare-SPOFeatures -SourceSiteURL "https://crescent.sharepoint.com/sites/marketing" -TargetSiteURL "https://crescent.sharepoint.com/sites/creditpipeline" -Scope Site
