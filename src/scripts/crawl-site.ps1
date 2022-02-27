# Source: https://gist.github.com/Swimburger/c2def1ea0dcb53d3d23030296c6e1b6c

Param(
    [Parameter(Mandatory=$true)]
    [string] $Url, 
    [Parameter(Mandatory=$true)]
    [int] $MaxPages, 
    [bool] $IncludeImages = $true, 
    [bool] $StayOnDomain = $true, 
    [bool] $IgnoreFragments = $true)

Add-Type -AssemblyName System.Web

$Domain = [Uri]::new($Url).Host;

Function Get-AbsoluteUrl([string]$pageUrl) {
    Begin {
        [Uri]$baseUri = [Uri]::new($pageUrl);
    }
    Process {
        $DecodedUrl = $_.Replace('&amp;', '&');
        If ([system.uri]::IsWellFormedUriString($DecodedUrl, [System.UriKind]::Absolute)) {
            $DecodedUrl
        }Else{
            [Uri]::new($baseUri, [string]$DecodedUrl).AbsoluteUri;
        }
    }
}

Function Remove-Fragments(){
    Process {
        $Uri = [Uri]::new([string]$_);
        If($Uri.Fragment -ne $null -and $Uri.Fragment -ne ''){
            $Uri.AbsoluteUri.Replace($Uri.Fragment, '');
        }Else{
            $_;
        }
    }
}

[System.Collections.ArrayList]$UrlsToCrawl = [System.Collections.ArrayList]@($Url);
$CrawlIndex = 0;
Do
{
    $Url = $UrlsToCrawl[$CrawlIndex];
    $CrawlIndex++;
    Try{
        $Response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 30;
        Write-Host ($CrawlIndex): $Response.StatusCode - $Url;
        $UrlsToCrawl = ($UrlsToCrawl + ($Response.Links.href | Where-Object { $_ -ne $null } | Get-AbsoluteUrl -pageUrl $Url)) | Select -Unique;

        if($IncludeImages){
            $UrlsToCrawl = ($UrlsToCrawl + ($Response.Images.src | Where-Object { $_ -ne $null } | Get-AbsoluteUrl -pageUrl $Url)) | Select -Unique;
        }

        if($StayOnDomain){
            $UrlsToCrawl = $UrlsToCrawl | Where-Object { [Uri]::new($_).Host -eq $Domain };
        }

        if($IgnoreFragments){
            $UrlsToCrawl = $UrlsToCrawl | Remove-Fragments | select -Unique
        }
    }Catch [System.Net.WebException] {
        Write-Warning ($CrawlIndex.ToString() + ": " + ([int]$_.Exception.Response.StatusCode).ToString() + " - " + $Url);
    }Catch {
        Write-Warning ($CrawlIndex.ToString() + ": Unknown error occurred - Url: " + $Url);
        Write-Error $_.Exception;
    }
}While ($CrawlIndex -lt $MaxPages -and $UrlsToCrawl.Count -gt $CrawlIndex)