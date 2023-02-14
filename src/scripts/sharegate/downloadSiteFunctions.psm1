<#
.DESCRIPTION
   Exports list contents from a web using ShareGate PowerShell functions
.EXAMPLE
   Export-SympLists -ParentFolder $parentFolder -WebUrl $webUrl -Versions $versions
#>
function Export-SympLists {
   [CmdletBinding()]
   [Alias()]
   [OutputType([int])]
   Param
   (
      # Parent Folder
      [string]
      $ParentFolder,
 
      # Web URL
      [string]
      $WebUrl,
 
      # Versions - Should we download versions (or only the latest version) $true = all versions
      [boolean]
      $Versions = $false,
 
      # ExclusionLists - Array of list names to *skip* in the download
      [array]
      $ExclusionLists = @(),

      # KeepEmpty - Will create a folder for every library even if it is empty.
      # Setting this to $false will delete the empty folders.
      [boolean]
      $KeepEmpty = $false,

      # KeepLists - Will create a folder for every list even if it is empty.
      # Setting this to $true will keep all lists, regardless of their number of items.
      [boolean]
      $KeepLists = $false
 
   )
  
   Begin {
  
      Write-Host "Processing web $($WebUrl)"
 
   }
   Process {
  
      # ShareGate's Connect-Site
      $srcSite = Connect-Site $WebUrl

      # ShareGate's Get-List
      $srcLists = Get-List -Site $srcSite

      # Filter out the exclusionList items, if any
      foreach ($exclusionList in $ExclusionLists) {
         $newLists = $srcLists | Where-Object { $_.Title -ne $exclusionList } 
         $srcLists = $newLists
      }

      # If there's something to download, do it.
      if ($srcLists.length -gt 0) {
         # If we want to keep versions 
         if ($Versions) {
            $result = Export-List -List $srcLists -DestinationFolder "$($ParentFolder)"
         }
         else {
            # Else we don't want to keep versions 
            $result = Export-List -List $srcLists -DestinationFolder "$($ParentFolder)" -NoVersionHistory 
         }
      }

      # If #KeepLists, then keep all lists
      if ($KeepLists) {
         $srcLists = $srcLists | Where-Object { $_.RootFolder -inotmatch "/Lists/" }
      }

      # If !$KeepEmpty, delete the folders which have no content
      if (!$KeepEmpty) {
         foreach ($list in $srcLists) {
            $listPath = "$($ParentFolder)\$($list.Title)"
            $documents = Get-Item -Path "$($listPath)\Documents\*" -ErrorAction Ignore
            if ($documents.length -eq 0) {
               Remove-Item -Path $listPath -Force -Confirm:$false -Recurse
            }
         }
      }

   }
   End {
   }
}
 
 
<#
 .DESCRIPTION
    Gets the subwebs of any web and exports their list contents using ShareGate PowerShell functions
 .EXAMPLE
    Get-SympSubwebs -ParentFolder $parentFolder -WebUrl $webUrl -Versions $versions 
 #>
function Get-SympSubwebs {
   [CmdletBinding()]
   [Alias()]
   [OutputType([int])]
   Param
   (
      # Parent Folder
      [string]
      $ParentFolder,
 
      # Web URL
      [string]
      $WebUrl,
 
      # Versions - Should we download versions (or only the latest version) $true = all versions
      [boolean]
      $Versions,
 
      # ExclusionLists - Array of list names to skip in the download
      [array]
      $ExclusionLists,

      # KeepEmpty - Will create a folder for every library even if it is empty.
      # Setting this to $false will delete the empty folders.
      [boolean]
      $KeepEmpty = $false,

      # KeepLists - Will create a folder for every list even if it is empty.
      # Setting this to $true will keep all lists, regardless of their number of items.
      [boolean]
      $KeepLists = $false

   )
  
   Begin {
  
      Write-Host "Getting subwebs of $($WebUrl)"
 
   }
   Process {
  
      # ShareGate's Connect-Site
      $siteConnection = Connect-Site $WebUrl

      # ShareGate's Get-Subsite
      $webs = Get-Subsite -Site $siteConnection
 
      # Process each web
      foreach ($web in $webs) {
 
         # Remove illegal characters in the web title
         $cleanTitle = $web.Title.Replace("#", "").Replace(":", " - ").Replace("/", "-").Replace("""", "'")

         # Variable for the web's folder - note the leading "_"
         $rootFolder = "$($ParentFolder)\_$($cleanTitle)" 
 
         # Create the web's folder
         $newFolder = New-Item -Path $rootFolder -ItemType Directory -Force

         # Download the lists/libraries with the provided parameters
         Export-SympLists -ParentFolder $rootFolder -WebUrl "$($web.Address)" -Versions $Versions -ExclusionLists $ExclusionLists -KeepEmpty $KeepEmpty -KeepLists $KeepLists

         # Get the web's subwebs - this is the recursion
         Get-SympSubwebs -ParentFolder $rootFolder -WebUrl "$($web.Address)" -Versions $Versions -ExclusionLists $ExclusionLists -KeepEmpty $KeepEmpty -KeepLists $KeepLists

      }
 
   }
   End {
   }
}