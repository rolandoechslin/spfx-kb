# Source: https://www.koskila.net/how-to-export-the-ssl-tls-certificate-a-website-from-a-website-using-powershell/

# Run this script in PowerShell 5, not 6/7 as they are built on .NET Core and don't support ServicePoint!

$url = "https://www.contoso.com"

$webRequest = [Net.WebRequest]::Create($url)
try { $webRequest.GetResponse() } catch {}

# Exported certificate(s) will be created in a timestamped subfolder of your working directory
$timestamp = (Get-Date).ToString("yyyy-MM-dd_hh-mm-ss")

mkdir $timestamp

$cert = $webRequest.ServicePoint.Certificate
$bytes = $cert.Export([Security.Cryptography.X509Certificates.X509ContentType]::Cert)

$chain = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Chain
$chain.build($cert)
$chain.ChainElements.Certificate | % {set-content -value $($_.Export([Security.Cryptography.X509Certificates.X509ContentType]::Cert)) -encoding byte -path "$pwd\$($timestamp)\$($_.Thumbprint).cer"}