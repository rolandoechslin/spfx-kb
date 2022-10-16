Function Encode-HumanReadability{
 <#
		.SYNOPSIS
		Changes the encoding values for better human readability
		
		.PARAMETER SiteURL
		The content to be decoded

		.EXAMPLE
		$Content = Encode-HumanReadability -ContentRaw $MyText
#>

		
    Param
    (
        [Parameter(Mandatory=$true)]$ContentRaw
    )


    $ContentHuman = $ContentRaw.replace("&#58;", ":")
    $ContentHuman = $ContentHuman.replace("&quot;", '"')
    $ContentHuman = $ContentHuman.replace("&#123;", "<")
    $ContentHuman = $ContentHuman.replace("&#125;", ">")
    $ContentHuman = $ContentHuman.replace("&gt;", ">")
    $ContentHuman = $ContentHuman.replace("&lt;", "<")

    Return $ContentHuman
}



# $Content = Encode-HumanReadability -ContentRaw $MyText
