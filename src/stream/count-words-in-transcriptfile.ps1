# Look for the 'streamContent?format=json' URL in the DevTools Network tab.

(Get-Clipboard | ConvertFrom-Json).entries | 
group speakerDisplayName | % {
    [PSCustomObject]@{
        Speaker = $_.Name
        Words = (-split ($_.Group.Text -join " ")).Count
    }
}