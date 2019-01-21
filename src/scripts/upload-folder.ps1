# Original: http://www.sharepointdiary.com/2018/01/upload-folder-to-sharepoint-online-using-powershell.html

# Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
 
#Function to Check if Folder Exists. If not, Create the Folder
Function Ensure-SPOFolder()
{
    param
    (
        [Parameter(Mandatory=$true)] [string] $FolderRelativeURL
    )
 
    #Check Folder Exists
    Try {
        $Folder = $Web.GetFolderByServerRelativeUrl($FolderRelativeURL)
        $Ctx.Load($Folder)
        $Ctx.ExecuteQuery()
  
        #Write-host -f Green "Folder Already Exists!"
    }
    Catch {
        #Create New Sub-Folder
        $Folder=$Web.Folders.Add($FolderRelativeURL)
        $Ctx.ExecuteQuery()
        Write-host -f Green "Created Folder at "$FolderRelativeURL
    }
}
 
#Function to Upload a File to a SharePoint Online
Function Upload-SPOFile()   
{
    param
    (
        [Parameter(Mandatory=$true)] [string] $SourceFilePath,
        [Parameter(Mandatory=$true)] [string] $TargetFileURL
    )
     
    #Get the file from disk
    $FileStream = ([System.IO.FileInfo] (Get-Item $SourceFilePath)).OpenRead()
    #Get File Name from source file path
    $SourceFileName = Split-path $SourceFilePath -leaf
    
    #Upload the File to SharePoint Library
    $FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
    $FileCreationInfo.Overwrite = $true
    $FileCreationInfo.ContentStream = $FileStream
    $FileCreationInfo.URL = $TargetFileURL
    $FileUploaded = $TargetFolder.Files.Add($FileCreationInfo)
   
    $Ctx.ExecuteQuery() 
    #Close file stream
    $FileStream.Close()
    Write-host "File '$TargetFileURL' Uploaded Successfully!" -ForegroundColor Green
}
  
#Main Function to upload a Local Folder to SharePoint Online Documnet Library Folder
Function Upload-SPOFolder()
{
    param
    (
        [Parameter(Mandatory=$true)] [string] $SourceFolderPath,
        [Parameter(Mandatory=$true)] [Microsoft.SharePoint.Client.Folder] $TargetFolder       
    )
 
    #Get All Files and Sub-Folders from Source
    Get-ChildItem $SourceFolderPath -Recurse | ForEach-Object {
        If ($_.PSIsContainer -eq $True)
        {
            $FolderRelativeURL = $TargetFolder.ServerRelativeURL+$_.FullName.Replace($SourceFolderPath,"").Replace("\","/")
            If($FolderRelativeURL)
            {
                Write-host -f Yellow "Ensuring Folder '$FolderRelativeURL' Exists..."
                Ensure-SPOFolder -FolderRelativeURL $FolderRelativeURL
            } 
        }
        Else
        {
            $FolderRelativeUrl = $TargetFolder.ServerRelativeURL + $_.DirectoryName.Replace($SourceFolderPath,"").Replace("\","/")
            $FileRelativeURL = $FolderRelativeUrl+"/"+$_.Name
            Write-host -f Yellow "Uploading File '$_' to URL "$FileRelativeURL
            Upload-SPOFile -SourceFilePath $_.FullName -TargetFileURL $FileRelativeURL
        }
    }
}
 
#Set parameter values
$SiteURL="https://crescent.sharepoint.com/sites/marketing"
$LibraryName="Documents"
$SourceFolderPath="C:\Users\salaudeen\Desktop\Marketing\Documents"
  
#Setup Credentials to connect
$Cred= Get-Credential
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
  
#Setup the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Ctx.Credentials = $Credentials
       
#Get the Target Folder to Upload
$Web = $Ctx.Web
$Ctx.Load($Web)
$List = $Web.Lists.GetByTitle($LibraryName)
$Ctx.Load($List)
$Ctx.Load($List.RootFolder)
$Ctx.ExecuteQuery()
  
#Call the function to Upload All files & folders from local folder to SharePoint Online
Upload-SPOFolder -SourceFolderPath $SourceFolderPath -TargetFolder $List.RootFolder


#Read more: http://www.sharepointdiary.com/2018/01/upload-folder-to-sharepoint-online-using-powershell.html#ixzz5dDTszgZY