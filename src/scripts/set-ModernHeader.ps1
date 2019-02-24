# https://mattipaukkonen.com/2019/02/18/modifying-modern-site-header-layout-with-code/

Connect-PnPOnline <site url>
$web = Get-PnPWeb -Includes HeaderEmphasis,HeaderLayout,SiteLogoUrl
$web.HeaderLayout = "Compact" #Options: Standard, Compact
$web.HeaderEmphasis = "Strong" #Options None,Neutral,Soft,Strong
$web.SiteLogoUrl = <Url to your logo>

$web.Update()
Invoke-PnPQuery