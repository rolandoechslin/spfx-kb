
# ======================================================
# Tip 1:
# ======================================================

# Source: https://helloitsliam.com/2021/10/22/microsoft-graph-powershell-backticks-vs-splatting-vs-class-objects/

# V1: Backticks
$password = New-Object `
    -TypeName Microsoft.Graph.PowerShell.Models.MicrosoftGraphPasswordProfile
$password.Password = "password"
$user = "user"
$displayname = "firstname lastname"

New-MgUser `
    -DisplayName $displayname
    -PasswordProfile $password
    -UserPrincipalName $user
    -AccountEnabled
    -MailNickName $displayname.Replace(' ', '')

# V2: Splatting

$Params = @{
    DisplayName  = $displayname;
    PasswordProfile = $password;
    UserPrincipalName = $user;
    AccountEnabled = $true;
    MailNickName = $displayname.Replace(' ','');
}
 
New-MgUser @Params

# V2: Class Object

Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"
Get-MgUser | Get-Member

$user = New-Object `
 -TypeName Microsoft.Graph.PowerShell.Models.MicrosoftGraphUser1

 $user.DisplayName = $displayname
 $user.PasswordProfile = $password
 $user.UserPrincipalName = $userprincipale
 $user.AccountEnabled = $true
 $user.MailNickName = $displayname.Replace(' ', '')

 New-MgUser -BodyParameter $user

 # ======================================================
