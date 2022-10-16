Function Test-URL{
<#
		.SYNOPSIS
		Test if URL is reachable
		
		.PARAMETER URL
		The URL to be checked

		.EXAMPLE
		$URLStatus = Test-URL -URL https://MyTenant.sharepoint.com
#>
	
    Param
    (
        [Parameter(Mandatory=$true)]$URL
    )

    # Is the parameter received a file or a site page ?
    try{
        switch -regex ($URL){
            ".pdf$"  {write-host "The file is a pdf" ; $IsFile = $true}
            ".docx$" {write-host "The file is a Word"; $IsFile = $true}
            Default  {write-host "This is site page" ; $IsFile = $false}
        }

        if($IsFile){
            if(Test-Path -Path URL){
                $Status = "OK"
            }
            else{
                $Status = "NOK"
            }
        }
        else{
		# if this step goes wrong, try using Invoke-WebRequest $URL -UseBasicParsing
            $SiteStatus = Invoke-WebRequest $URL

            if($SiteStatus.StatusCode -eq "200"){
                write-host "Link OK" -f green
                $Status = "OK"
            }
        }
    
    }
    catch{
        write-host "Dead Link"-f red 
        #write-host $Error[0].Exception
        write-host $Error[0] -f red 
        $Status = "NOK"
    }

    Return $Status
}
