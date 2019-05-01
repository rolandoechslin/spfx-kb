# Source: http://www.sharepointdiary.com/2018/06/sharepoint-online-get-folder-size-using-powershell.html

#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
   
#Function to Get the size of a Folder in SharePoint Online
Function Get-SPOFolderSize([Microsoft.SharePoint.Client.Folder]$Folder)
{
     Try
     {
        #Get all Files and Subfolders from the folder
        $Ctx.Load($Folder.Files)
        $Ctx.Load($Folder.Folders)
        $Ctx.ExecuteQuery()
 
        $FolderSize = 0
        ForEach($File in $Folder.Files | Where {-Not($_.Name.EndsWith(".aspx"))})
        {
            #Get File versions
            $Ctx.Load($File.Versions)
            $Ctx.ExecuteQuery()
            $VersionSize=0
            If($File.Versions.Count -ge 1)
            {
                #Calculate Version Size
                $VersionSize = $File.Versions | Measure-Object -Property Size -Sum | Select-Object -expand Sum                               
            }
            $FileSize =  [Math]::Round((($File.Length) + $VersionSize)/1KB, 2)
            If($FileSize -gt 0)
            {
                Write-host "`tSize of the File '$($File.Name)' "$FileSize
            }
 
            #Get File Size
            $FolderSize += $FileSize
        }
 
        If($FolderSize -gt 0)
        {
            Write-host -f Yellow "Total Size of the Folder '$($Folder.ServerRelativeUrl)' (KB): " -NoNewline
            $FolderSize= [Math]::Round($FolderSize/1KB, 2)
            Write-host $FolderSize
        }
        #Process all Sub Folders
        ForEach($Folder in $Folder.Folders | Where {-Not($_.Name.StartsWith("_") -or $_.Name -eq "Forms")})
        {
            #Call the function recursively
            Get-SPOFolderSize $Folder
        }
    }
    Catch [System.Exception]
    {
        Write-Host -f Red "Error:"$_.Exception.Message
    }
}
   
#parameters
$SiteURL = "https://crescenttech.sharepoint.com"
 
#Get credentials to connect to SharePoint Online Admin Center
$Cred = Get-Credential
   
#Set up the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
     
#Get the Web
$Web = $Ctx.Web
$RootFolder = $Web.RootFolder
$Ctx.Load($RootFolder)
$Ctx.ExecuteQuery()
  
#Call the function to get Subsite size
Get-SPOFolderSize -Folder $RootFolder