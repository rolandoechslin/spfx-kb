<#
.SYNOPSIS
  Connect to Office 365 services via PowerShell

.DESCRIPTION
  This script will prompt for your Office 365 tenant credentials and connect you to any or all Office 365 services via remote PowerShell

.INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version:        1.1
  Author:         Chris Goosen (Twitter: @chrisgoosen)
  Creation Date:  02/06/2019
  Credits:        ExchangeMFAModule handling by Michel de Rooij - eightwone.com, @mderooij
                  Bugfinder extraordinaire Greig Sheridan - greiginsydney.com, @greiginsydney

.LINK
  http://www.cgoosen.com

.EXAMPLE
  .\Connect-365.ps1
#>
$ErrorActionPreference = "Stop"

#region XAML code
$XAML = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Connect-365" Height="420" Width="550" ResizeMode="NoResize" WindowStartupLocation="CenterScreen">
    <Grid>
        <DockPanel>
            <Menu DockPanel.Dock="Top">
                <MenuItem Header="_File">
                    <MenuItem Name="Btn_Exit" Header="_Exit" />
                </MenuItem>

                <MenuItem Header="_Edit">
                    <MenuItem Command="Cut" />
                    <MenuItem Command="Copy" />
                    <MenuItem Command="Paste" />
                </MenuItem>

                <MenuItem Header="_Help">
                    <MenuItem Header="_About">
                        <MenuItem Name="Btn_About" Header="_Script Version 1.1"/>
                        </MenuItem>
                    <MenuItem Name="Btn_Help" Header="_Get Help" />
                </MenuItem>
            </Menu>
        </DockPanel>
        <TabControl Margin="0,20,0,0">
            <TabItem Name="Tab_Connection" Header="Connection Options" TabIndex="12">
                <Grid Background="White">
                    <StackPanel>
                        <StackPanel Height="32" HorizontalAlignment="Center" VerticalAlignment="Top" Width="538" Margin="0,0,0,0">
                            <Label Content="Office 365 Remote PowerShell" HorizontalAlignment="Center" VerticalAlignment="Top" Margin="0" Height="32" FontWeight="Bold"/>
                        </StackPanel>
                        <StackPanel Height="32" HorizontalAlignment="Center" VerticalAlignment="Top" Width="538" Margin="0,0,0,0" Orientation="Horizontal">
                            <Label Content="Username:" HorizontalAlignment="Left" Height="32" Margin="10,0,0,0" VerticalAlignment="Center" Width="70" FontSize="11" VerticalContentAlignment="Center"/>
                            <TextBox Name="Field_User" HorizontalAlignment="Left" Height="22" Margin="0,0,0,0" TextWrapping="Wrap" VerticalAlignment="Center" Width="438" VerticalContentAlignment="Center" FontSize="11" BorderThickness="1" TabIndex="1"/>
                        </StackPanel>
                        <StackPanel Height="32" HorizontalAlignment="Center" VerticalAlignment="Top" Width="538" Margin="0,0,0,0" Orientation="Horizontal">
                            <Label Content="Password:" HorizontalAlignment="Left" Height="32" Margin="10,0,0,0" VerticalAlignment="Center" Width="70" FontSize="11" VerticalContentAlignment="Center"/>
                            <PasswordBox Name="Field_Pwd" HorizontalAlignment="Left" Height="22" Margin="0,0,0,0" VerticalAlignment="Center" Width="438" VerticalContentAlignment="Center" FontSize="11" BorderThickness="1" TabIndex="2"/>
                        </StackPanel>
                        <StackPanel HorizontalAlignment="Center" VerticalAlignment="Top" Width="538" Margin="0,10,0,0">
                            <GroupBox Header="Services:" Width="508" Margin="10,0,0,0" FontSize="11" HorizontalAlignment="Left" VerticalAlignment="Top">
                                <Grid Height="60" Margin="0,10,0,0">
                                    <CheckBox Name="Box_EXO" TabIndex="3" HorizontalAlignment="Left" VerticalAlignment="Top">Exchange Online</CheckBox>
                                    <CheckBox Name="Box_AAD" TabIndex="4" HorizontalAlignment="Center" VerticalAlignment="Top">Azure AD</CheckBox>
                                    <CheckBox Name="Box_Com" TabIndex="5" HorizontalAlignment="Right" VerticalAlignment="Top">Compliance Center</CheckBox>
                                    <CheckBox Name="Box_SPO" TabIndex="6" HorizontalAlignment="Left" VerticalAlignment="Center">SharePoint Online</CheckBox>
                                    <CheckBox Name="Box_SfB" TabIndex="7" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="78,0,0,0">Skype for Business Online</CheckBox>
                                    <CheckBox Name="Box_Teams" TabIndex="8" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,62,0">Teams</CheckBox>
                                    <CheckBox Name="Box_Intune" TabIndex="9" HorizontalAlignment="Left" VerticalAlignment="Bottom">Intune</CheckBox>
                                </Grid>
                            </GroupBox>
                            <GroupBox Header="Options:" Width="508" Margin="10,10,0,0" FontSize="11" HorizontalAlignment="Left" VerticalAlignment="Top">
                                <Grid Height="50" Margin="0,10,0,0">
                                  <CheckBox Name="Box_MFA" TabIndex="10" HorizontalAlignment="Left" VerticalAlignment="Top">Use MFA?</CheckBox>
                                  <CheckBox Name="Box_Clob" TabIndex="11" HorizontalAlignment="Center" VerticalAlignment="Top" IsEnabled="False" Margin="20,0,0,0">AllowClobber</CheckBox>
                                    <StackPanel HorizontalAlignment="Left" VerticalAlignment="Bottom" Orientation="Horizontal">
                                        <Label Content="Admin URL:" Width="70"></Label>
                                        <TextBox Name="Field_SPOUrl" Height="22" Width="425" Margin="0,0,0,0" TextWrapping="Wrap" IsEnabled="False" TabIndex="12"></TextBox>
                                    </StackPanel>
                                </Grid>
                            </GroupBox>
                        </StackPanel>
                        <StackPanel Height="45" Orientation="Horizontal" VerticalAlignment="Top" HorizontalAlignment="Center" Margin="0,10,0,0">
                            <Button Name="Btn_Ok" Content="Ok" Width="75" Height="25" VerticalAlignment="Top" HorizontalAlignment="Center" TabIndex="13" />
                            <Button Name="Btn_Cancel" Content="Cancel" Width="75" Height="25" VerticalAlignment="Top" HorizontalAlignment="Center" Margin="40,0,0,0" TabIndex="14" />
                        </StackPanel>
                    </StackPanel>
                </Grid>
            </TabItem>
            <TabItem Name="Tab_Prereq" Header="Prerequisite Checker" TabIndex="11">
                <Grid Background="White">
                    <StackPanel>
                        <StackPanel>
                            <Grid Margin="0,10,0,0">
                                <Label Content="Module" HorizontalAlignment="Left" FontSize="11" FontWeight="Bold"/>
                                <Label Content="Status" HorizontalAlignment="Center" FontSize="11" FontWeight="Bold"/>
                            </Grid>
                            <StackPanel>
                                <Label BorderBrush="Black" BorderThickness="0,0,0,1" VerticalAlignment="Top"/>
                            </StackPanel>
                        </StackPanel>
                        <StackPanel>
                            <Grid Margin="0,10,0,0">
                                <Label Content="Azure AD Version 2" HorizontalAlignment="Left" FontSize="11"/>
                                <TextBlock Name="Txt_AADStatus" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11" />
                                <Button Name="Btn_AADMsg" Content="Download now.." Width="125" Height="25" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,10,0" />
                            </Grid>
                        </StackPanel>
                        <StackPanel>
                            <Grid Margin="0,10,0,0">
                                <Label Content="SharePoint Online" HorizontalAlignment="Left" FontSize="11"/>
                                <TextBlock Name="Txt_SPOStatus" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11" />
                                <Button Name="Btn_SPOMsg" Content="Download now.." Width="125" Height="25" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,10,0" />
                            </Grid>
                        </StackPanel>
                        <StackPanel>
                            <Grid Margin="0,10,0,0">
                                <Label Content="Skype for Business Online" HorizontalAlignment="Left" FontSize="11"/>
                                <TextBlock Name="Txt_SfBStatus" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11" />
                                <Button Name="Btn_SfBMsg" Content="Download now.." Width="125" Height="25" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,10,0" />
                            </Grid>
                        </StackPanel>
                            <Grid Margin="0,10,0,0">
                                <Label Content="Exchange Online" HorizontalAlignment="Left" FontSize="11"/>
                                <TextBlock Name="Txt_EXOStatus" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11" />
                            <Button Name="Btn_EXOMsg" Content="Download now.." Width="125" Height="25" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,10,0" />
                        </Grid>
                        <StackPanel>
                          <Grid Margin="0,10,0,0">
                              <Label Content="Teams" HorizontalAlignment="Left" FontSize="11"/>
                              <TextBlock Name="Txt_TeamsStatus" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11" />
                          <Button Name="Btn_TeamsMsg" Content="Download now.." Width="125" Height="25" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,10,0" />
                    </Grid>
                        </StackPanel>
                        <StackPanel>
                          <Grid Margin="0,10,0,0">
                              <Label Content="Intune (MS Graph)" HorizontalAlignment="Left" FontSize="11"/>
                              <TextBlock Name="Txt_IntuneStatus" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11" />
                          <Button Name="Btn_IntuneMsg" Content="Download now.." Width="125" Height="25" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,10,0" />
                    </Grid>
                        </StackPanel>
                    </StackPanel>
                </Grid>
            </TabItem>
        </TabControl>
    </Grid>
</Window>
"@

#endregion

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAMLGui = $XAML

$Reader=(New-Object System.Xml.XmlNodeReader $XAMLGui)
$MainWindow=[Windows.Markup.XamlReader]::Load( $Reader )
$XAMLGui.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name "GUI$($_.Name)" -Value $MainWindow.FindName($_.Name)}

# Functions
Function Get-Options{
        If ($GUIBox_EXO.IsChecked -eq "True") {
            $Script:ConnectEXO = $true
            $OptionsArray++
    }
        If ($GUIBox_AAD.IsChecked -eq "True") {
            $Script:ConnectAAD = $true
            $OptionsArray ++
    }
        If ($GUIBox_Com.IsChecked -eq "True") {
            $Script:ConnectCom = $true
            $OptionsArray++
    }
        If ($GUIBox_SfB.IsChecked -eq "True") {
            $Script:ConnectSfB = $true
            $OptionsArray++
    }
        If ($GUIBox_SPO.IsChecked -eq "True") {
            $Script:ConnectSPO = $true
            $OptionsArray++
    }
        If ($GUIBox_Teams.IsChecked -eq "True") {
            $Script:ConnectTeams = $true
            $OptionsArray++
    }
        If ($GUIBox_Intune.IsChecked -eq "True") {
            $Script:ConnectIntune = $true
            $OptionsArray++
    }
        If ($GUIBox_MFA.IsChecked -eq "True") {
            $Script:UseMFA = $true
    }
        If ($GUIBox_Clob.IsChecked -eq "True") {
            $Script:Clob = $true
    }
}

Function Get-UserPwd{
        If (!$Username -or !$Pwd) {
            $MainWindow.Close()
            Close-Window "Please enter valid credentials..`nScript failed"
    }
        ElseIf ($OptionsArray -eq "0") {
            $MainWindow.Close()
            Close-Window "Please select a valid option..`nScript failed"
    }
}

Function Connect-EXO{
    If ($UseMFA) {
      $EXOSession = New-EXOPSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ -UserPrincipalName $UserName
    }
    Else {
      $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
    }
    If ($Clob) {
      Import-PSSession $EXOSession -AllowClobber
    }
    Else {
      Import-PSSession $EXOSession
    }
}

Function Connect-AAD{
    If ($UseMFA) {
      Connect-AzureAD -AccountId $UserName
    }
    Else {
      Connect-AzureAD -Credential $Credential
    }
}

Function Connect-Com{
    If ($UseMFA) {
      $CCSession = New-EXOPSSession -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -UserPrincipalName $UserName
    }
    Else {
      $CCSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
    }
    If ($Clob) {
      Import-PSSession $CCSession -AllowClobber
    }
    Else {
      Import-PSSession $CCSession
    }
}

Function Connect-SfB{
    If ($UseMFA) {
      $SfBSession = New-CsOnlineSession -UserName $UserName
    }
    Else {
      $SfBSession = New-CsOnlineSession -Credential $Credential
    }
    If ($Clob) {
      Import-PSSession $SfBSession -AllowClobber
    }
    Else {
      Import-PSSession $SfBSession
    }
}

Function Connect-SPO{
    If ($UseMFA) {
      Connect-SPOService -Url $GUIField_SPOUrl.text
    }
    Else {
      Connect-SPOService -Url $GUIField_SPOUrl.text -Credential $Credential
    }
}

Function Connect-Teams{
    If ($UseMFA) {
      Connect-MicrosoftTeams -AccountId $UserName
    }
    Else {
      Connect-MicrosoftTeams -Credential $Credential
    }
}

Function Connect-Intune{
    If ($UseMFA) {
      Connect-MSGraph
    }
    Else {
      Connect-MSGraph -PSCredential $Credential
    }
}

Function Get-ModuleInfo-AAD{
      try {
          Import-Module -Name AzureAD
          return $true
      }
      catch {
          return $false
      }
}

Function Get-ModuleInfo-SfB{
      try {
          Import-Module -Name SkypeOnlineConnector
          return $true
      }
      catch {
          return $false
      }
}

Function Get-ModuleInfo-SPO{
    try {
        Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
        return $true
    }
    catch {
        return $false
    }
}

# ExchangeMFAModule handling by Michel de Rooij - eightwone.com, @mderooij
Function Get-ModuleInfo-EXO{
    try {
        $ExchangeMFAModule = 'Microsoft.Exchange.Management.ExoPowershellModule'
        $ModuleList = @(Get-ChildItem -Path "$($env:LOCALAPPDATA)\Apps\2.0" -Filter "$($ExchangeMFAModule).manifest" -Recurse ) | Sort-Object LastWriteTime -Desc | Select-Object -First 1
        If ( $ModuleList) {
          $ModuleName = Join-path -Path $ModuleList[0].Directory.FullName -ChildPath "$($ExchangeMFAModule).dll"
        }
        Import-Module -FullyQualifiedName $ModuleName -Force
        return $true
    }
    catch {
        return $false
    }
}

Function Get-ModuleInfo-Teams{
    try {
        Import-Module -Name MicrosoftTeams
        return $true
    }
    catch {
        return $false
    }
}

Function Get-ModuleInfo-Intune{
    try {
        Import-Module -Name Microsoft.Graph.Intune
        return $true
    }
    catch {
        return $false
    }
}


function Close-Window ($CloseReason) {
    Write-Host "$CloseReason" -ForegroundColor Red
    Exit
}

function Get-FailedMsg ($FailedReason) {
    Write-Host "$FailedReason. Connection failed, please check your credentials and try again.." -ForegroundColor Red
    Exit
}

function Get-PreReq-AAD{
    If (Get-ModuleInfo-AAD -eq "True") {
        $GUITxt_AADStatus.Text = "OK!"
        $GUITxt_AADStatus.Foreground = "Green"
        $GUIBtn_AADMsg.IsEnabled = $false
        $GUIBtn_AADMsg.Opacity = "0"
    }
    else {
        $GUITxt_AADStatus.Text = "Failed!"
        $GUITxt_AADStatus.Foreground = "Red"
        $GUIBtn_AADMsg.IsEnabled = $true
    }
}

function Get-PreReq-SfB{
    If (Get-ModuleInfo-SfB -eq "True") {
        $GUITxt_SfBStatus.Text = "OK!"
        $GUITxt_SfBStatus.Foreground = "Green"
        $GUIBtn_SfBMsg.IsEnabled = $false
        $GUIBtn_SfBMsg.Opacity = "0"
    }
    else {
        $GUITxt_SfBStatus.Text = "Failed!"
        $GUITxt_SfBStatus.Foreground = "Red"
        $GUIBtn_SfBMsg.IsEnabled = $true
    }
}

function Get-PreReq-SPO{
    If (Get-ModuleInfo-SPO -eq "True") {
        $GUITxt_SPOStatus.Text = "OK!"
        $GUITxt_SPOStatus.Foreground = "Green"
        $GUIBtn_SPOMsg.IsEnabled = $false
        $GUIBtn_SPOMsg.Opacity = "0"
    }
    else {
        $GUITxt_SPOStatus.Text = "Failed!"
        $GUITxt_SPOStatus.Foreground = "Red"
        $GUIBtn_SPOMsg.IsEnabled = $true
    }
}

function Get-PreReq-EXO{
    If (Get-ModuleInfo-EXO -eq "True") {
        $GUITxt_EXOStatus.Text = "OK!"
        $GUITxt_EXOStatus.Foreground = "Green"
        $GUIBtn_EXOMsg.IsEnabled = $false
        $GUIBtn_EXOMsg.Opacity = "0"
    }
    else {
        $GUITxt_SPOStatus.Text = "Failed!"
        $GUITxt_SPOStatus.Foreground = "Red"
        $GUIBtn_SPOMsg.IsEnabled = $true
    }
}

function Get-PreReq-Teams{
    If (Get-ModuleInfo-Teams -eq "True") {
        $GUITxt_TeamsStatus.Text = "OK!"
        $GUITxt_TeamsStatus.Foreground = "Green"
        $GUIBtn_TeamsMsg.IsEnabled = $false
        $GUIBtn_TeamsMsg.Opacity = "0"
    }
    else {
        $GUITxt_TeamsStatus.Text = "Failed!"
        $GUITxt_TeamsStatus.Foreground = "Red"
        $GUIBtn_TeamsMsg.IsEnabled = $true
    }
}

function Get-PreReq-Intune{
    If (Get-ModuleInfo-Intune -eq "True") {
        $GUITxt_IntuneStatus.Text = "OK!"
        $GUITxt_IntuneStatus.Foreground = "Green"
        $GUIBtn_IntuneMsg.IsEnabled = $false
        $GUIBtn_IntuneMsg.Opacity = "0"
    }
    else {
        $GUITxt_IntuneStatus.Text = "Failed!"
        $GUITxt_IntuneStatus.Foreground = "Red"
        $GUIBtn_IntuneMsg.IsEnabled = $true
    }
}
function Get-PreReq{
  Get-PreReq-AAD
  Get-PreReq-SfB
  Get-PreReq-SPO
  Get-PreReq-EXO
  Get-PreReq-Teams
  Get-PreReq-Intune
}

function Get-OKBtn{
  $Script:Username = $GUIField_User.Text
  $Pwd = $GUIField_Pwd.Password
  Get-Options
  Get-UserPwd
	$EncryptPwd = $Pwd | ConvertTo-SecureString -AsPlainText -Force
	$Script:Credential = New-Object System.Management.Automation.PSCredential($Username,$EncryptPwd)
  $Script:EndScript = 2
	$MainWindow.Close()
}

function Get-CancelBtn{
    $MainWindow.Close()
    $Script:EndScript = 1
	Close-Window 'Script cancelled'
}

# Event Handlers
$MainWindow.add_KeyDown({
    param
(
  [Parameter(Mandatory)][Object]$Sender,
  [Parameter(Mandatory)][Windows.Input.KeyEventArgs]$KeyPress
)
    if ($KeyPress.Key -eq "Enter"){
    Get-OKBtn
    }

    if ($KeyPress.Key -eq "Escape"){
    Get-CancelBtn
    }
})

$MainWindow.add_Closing({
    $Script:EndScript++
})

$GUIBtn_Cancel.add_Click({
    Get-CancelBtn
})

$GUIBtn_Ok.add_Click({
    Get-OKBtn
})

$GUITab_Prereq.add_Loaded({

})

$GUIBtn_AADMsg.add_Click({
    try {
        Start-Process -FilePath https://www.powershellgallery.com/packages/AzureAD
    }
    catch {
        $MainWindow.Close()
        Close-Window "An error occurred..`nExiting script"
    }
})

$GUIBtn_SfBMsg.add_Click({
    try {
        Start-Process -FilePath http://go.microsoft.com/fwlink/?LinkId=294688
    }
    catch {
        $MainWindow.Close()
        Close-Window "An error occurred..`nExiting script"
    }
})

$GUIBtn_SPOMsg.add_Click({
    try {
        Start-Process -FilePath http://go.microsoft.com/fwlink/p/?LinkId=255251
    }
    catch {
        $MainWindow.Close()
        Close-Window "An error occurred..`nExiting script"
    }
})

$GUIBtn_EXOMsg.add_Click({
    try {
        Start-Process -FilePath http://bit.ly/ExOPSModule
    }
    catch {
        $MainWindow.Close()
        Close-Window "An error occurred..`nExiting script"
    }
})

$GUIBtn_TeamsMsg.add_Click({
    try {
        Start-Process -FilePath https://www.powershellgallery.com/packages/MicrosoftTeams
    }
    catch {
        $MainWindow.Close()
        Close-Window "An error occurred..`nExiting script"
    }
})

$GUIBtn_IntuneMsg.add_Click({
    try {
        Start-Process -FilePath https://github.com/Microsoft/Intune-PowerShell-SDK
    }
    catch {
        $MainWindow.Close()
        Close-Window "An error occurred..`nExiting script"
    }
})

$GUIBox_EXO.add_Click({
    $GUIBox_Clob.IsEnabled = "True"
})

$GUIBox_Com.add_Click({
    $GUIBox_Clob.IsEnabled = "True"
})

$GUIBox_SfB.add_Click({
    $GUIBox_Clob.IsEnabled = "True"
})

$GUIBox_SPO.add_Checked({
    $GUIField_SPOUrl.IsEnabled = "True"
    $GUIField_SPOUrl.Text = "Enter your SharePoint Online Admin URL, e.g https://<tenant>-admin.sharepoint.com"
})

$GUIBox_SPO.add_UnChecked({
    $GUIField_SPOUrl.IsEnabled = "False"
    $GUIField_SPOUrl.Text = ""
})

$GUIField_SPOUrl.add_GotFocus({
    $GUIField_SPOUrl.Text = ""
})

$GUIBtn_Exit.add_Click({
    Get-CancelBtn
})

$GUIBtn_About.add_Click({
    Start-Process -FilePath http://cgoo.se/2ogotCK
})

$GUIBtn_Help.add_Click({
    Start-Process -FilePath http://cgoo.se/1srvTiS
})

# Script re-req checks
Write-Host "Starting script..`nLooking for installed modules.." -ForegroundColor Green
Get-PreReq
Write-Host "Done!" -ForegroundColor Green

# Load GUI Window
$MainWindow.WindowStartupLocation = "CenterScreen"
$MainWindow.ShowDialog() | Out-Null

# Check if Window is closed
If ($EndScript -eq 1){
    Close-Window 'Script cancelled'
}

# Connect to Skype for Business Online if required
If ($ConnectSfB -eq "True"){
     Try {
         Connect-Sfb
     }
     Catch 	{
         Get-FailedMsg 'Skype for Business Online error'
     }
 }

# Connect to EXO if required
If ($ConnectEXO -eq "True"){
        Try {
            Connect-EXO
        }
        Catch 	{
            Get-FailedMsg 'Exchange Online error'
        }
}

# Connect to SharePoint Online if required
If ($ConnectSPO-eq "True"){
    Try {
        Connect-SPO
    }
    Catch 	{
        Get-FailedMsg 'SharePoint Online error'
    }
}

# Connect to Security & Compliance Center if required
If ($ConnectCom -eq "True"){
    Try {
        Start-Sleep -Seconds 2
        Connect-Com
    }
    Catch 	{
        Get-FailedMsg 'Security & Compliance Center error'
    }
}

# Connect to AAD if required
If ($ConnectAAD -eq "True"){
    Try {
        Connect-AAD
    }
    Catch 	{
        Get-FailedMsg 'Azure AD error'
    }
}

# Connect to Teams if required
If ($ConnectTeams -eq "True"){
    Try {
        Connect-Teams
    }
    Catch 	{
        Get-FailedMsg 'Teams error'
    }
}

# Connect to Intune if required
If ($ConnectIntune -eq "True"){
    Try {
        Connect-Intune
    }
    Catch 	{
        Get-FailedMsg 'Intune error'
    }
}

# Notifications/Information
Clear-Host
Write-Host "
Your username is: $UserName" -ForegroundColor Yellow -BackgroundColor Black
Write-Host "You are now connected to:" -ForegroundColor Yellow -BackgroundColor Black
If ($ConnectEXO -eq "True"){
    Write-Host "-Exchange Online" -ForegroundColor Yellow -BackgroundColor Black
}
If ($ConnectAAD -eq "True"){
    Write-Host "-Azure Active Directory" -ForegroundColor Yellow -BackgroundColor Black
}
If ($ConnectCom -eq "True"){
    Write-Host "-Office 365 Security & Compliance Center" -ForegroundColor Yellow -BackgroundColor Black
}
If ($ConnectSfB -eq "True"){
    Write-Host "-Skype for Business Online" -ForegroundColor Yellow -BackgroundColor Black
}
If ($ConnectSPO -eq "True"){
    Write-Host "-SharePoint Online" -ForegroundColor Yellow -BackgroundColor Black
}
If ($ConnectTeams -eq "True"){
    Write-Host "-Teams" -ForegroundColor Yellow -BackgroundColor Black
}
If ($ConnectIntune -eq "True"){
    Write-Host "-Intune API" -ForegroundColor Yellow -BackgroundColor Black
}

# SIG # Begin signature block
# MIIcawYJKoZIhvcNAQcCoIIcXDCCHFgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnPejfBgl+HbA3L0S5lLlHubC
# exeggheaMIIFIzCCBAugAwIBAgIQBj1zuMh0hjKHysC4H/YGkDANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE5MDIyODAwMDAwMFoXDTE5MTIx
# OTEyMDAwMFowYDELMAkGA1UEBhMCVVMxDjAMBgNVBAgTBVRleGFzMRMwEQYDVQQH
# EwpDYXJyb2xsdG9uMRUwEwYDVQQKEwxDaHJpcyBHb29zZW4xFTATBgNVBAMTDENo
# cmlzIEdvb3NlbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANmBhAxT
# A5VapfHR2w5xDxmLW4XS3a4MJ8SdTp6tGGoCwAnSi5A2t44T+PFnwxySDAV4DZjb
# SXsVvyyA53E4aCO3xb4dGS+Q6dlDzmzmSNk11YrMsceMpw3CHQ+BYClMnzr5iowr
# axpjHsIBvbfC86/wUFUE0FKUWjlNjo4Ckx/RDWd9ORl25dGHeikM8tmeblHhEa9q
# a+NBsSBMqcSJKuV2D4im4nZwXCnNdP7+Tn2NOnP358NZKcQFx8nxXR1ZqhIcBo2n
# njTMbJhE0NxAc1EkfJAg4gUHZdq2kRxHQNTv2LFyKgOWV0CvGBnsJVISbVqYVu7t
# 0pyWGhiJJ2qjSWECAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nED
# wGD5LfZldQ5YMB0GA1UdDgQWBBTxv17fXK3u40we5zxGf4oW7h0KNjAOBgNVHQ8B
# Af8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYv
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmww
# NaAzoDGGL2h0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3Mt
# ZzEuY3JsMEwGA1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0
# dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcB
# AQR4MHYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggr
# BgEFBQcwAoZCaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hB
# MkFzc3VyZWRJRENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZI
# hvcNAQELBQADggEBAIGVhyevlVUct6yOCV3hNj4/q45oWptt519AfcLNlNhWUP/X
# uujN61Abr+2KeJNr7WGnHZmBguHBdT6hkZQiEVX/ysk3q1voVOHY5ln1cVVAEaZb
# gSciEMSMNrqknfMbfY71H7j5NjAaAw0aOi4aEAfVH7/1zrIUxbPyHWY74I0WHYIL
# PVS0ATyxe11nk2dsVR6GIPC8z2GFs3esAEzlGWeHw1Mijw2RkYmBmXPO7WwnZYWK
# cEpXICgdsMNFN66Njp+Qk2B0g3mxfrbVlCQyh28YclggN63EKr0llikcoR1npeEC
# yciQZQPd8MqtYWiV6Bt4ViVl3X1J2w2rTq2mb+4wggUwMIIEGKADAgECAhAECRgb
# X9W7ZnVTQ7VvlVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAi
# BgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAw
# MDBaFw0yODEwMjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERp
# Z2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE
# 9X/lqJ3bMtdx6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvsp
# J8fTeyOU5JEjlpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWu
# HEqHCN8M9eJNYBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel0
# 5iv+bMt+dDk2DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4P
# waLoLFH3c7y9hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHN
# MIIByTASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUE
# DDAKBggrBgEFBQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0f
# BHoweDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNz
# dXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG
# /WwAAgQwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQ
# UzAKBghghkgBhv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYD
# VR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEB
# AD7sDVoks/Mi0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh
# 9tGSdQ9RtG6ljlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6R
# Ffu6r7VRwo0kriTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEM
# j7uo+MUSaJ/PQMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutm
# Q9qzsIzV6Q3d9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUu
# kpHqaGxEMrJmoecYpJpkUe8wggZqMIIFUqADAgECAhADAZoCOv9YsWvW1ermF/Bm
# MA0GCSqGSIb3DQEBBQUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IEFzc3VyZWQgSUQgQ0EtMTAeFw0xNDEwMjIwMDAwMDBaFw0yNDEwMjIwMDAw
# MDBaMEcxCzAJBgNVBAYTAlVTMREwDwYDVQQKEwhEaWdpQ2VydDElMCMGA1UEAxMc
# RGlnaUNlcnQgVGltZXN0YW1wIFJlc3BvbmRlcjCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBAKNkXfx8s+CCNeDg9sYq5kl1O8xu4FOpnx9kWeZ8a39rjJ1V
# +JLjntVaY1sCSVDZg85vZu7dy4XpX6X51Id0iEQ7Gcnl9ZGfxhQ5rCTqqEsskYnM
# Xij0ZLZQt/USs3OWCmejvmGfrvP9Enh1DqZbFP1FI46GRFV9GIYFjFWHeUhG98oO
# jafeTl/iqLYtWQJhiGFyGGi5uHzu5uc0LzF3gTAfuzYBje8n4/ea8EwxZI3j6/oZ
# h6h+z+yMDDZbesF6uHjHyQYuRhDIjegEYNu8c3T6Ttj+qkDxss5wRoPp2kChWTrZ
# FQlXmVYwk/PJYczQCMxr7GJCkawCwO+k8IkRj3cCAwEAAaOCAzUwggMxMA4GA1Ud
# DwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MIIBvwYDVR0gBIIBtjCCAbIwggGhBglghkgBhv1sBwEwggGSMCgGCCsGAQUFBwIB
# FhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMIIBZAYIKwYBBQUHAgIwggFW
# HoIBUgBBAG4AeQAgAHUAcwBlACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBm
# AGkAYwBhAHQAZQAgAGMAbwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0
# AGEAbgBjAGUAIABvAGYAIAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAv
# AEMAUABTACAAYQBuAGQAIAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0
# AHkAIABBAGcAcgBlAGUAbQBlAG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAg
# AGwAaQBhAGIAaQBsAGkAdAB5ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBw
# AG8AcgBhAHQAZQBkACAAaABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBu
# AGMAZQAuMAsGCWCGSAGG/WwDFTAfBgNVHSMEGDAWgBQVABIrE5iymQftHt+ivlcN
# K2cCzTAdBgNVHQ4EFgQUYVpNJLZJMp1KKnkag0v0HonByn0wfQYDVR0fBHYwdDA4
# oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElE
# Q0EtMS5jcmwwOKA2oDSGMmh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRENBLTEuY3JsMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYY
# aHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2Fj
# ZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURDQS0xLmNydDANBgkq
# hkiG9w0BAQUFAAOCAQEAnSV+GzNNsiaBXJuGziMgD4CH5Yj//7HUaiwx7ToXGXEX
# zakbvFoWOQCd42yE5FpA+94GAYw3+puxnSR+/iCkV61bt5qwYCbqaVchXTQvH3Gw
# g5QZBWs1kBCge5fH9j/n4hFBpr1i2fAnPTgdKG86Ugnw7HBi02JLsOBzppLA044x
# 2C/jbRcTBu7kA7YUq/OPQ6dxnSHdFMoVXZJB2vkPgdGZdA0mxA5/G7X1oPHGdwYo
# FenYk+VVFvC7Cqsc21xIJ2bIo4sKHOWV2q7ELlmgYd3a822iYemKC23sEhi991VU
# QAOSK2vCUcIKSK+w1G7g9BQKOhvjjz3Kr2qNe9zYRDCCBs0wggW1oAMCAQICEAb9
# +QOWA63qAArrPye7uhswDQYJKoZIhvcNAQEFBQAwZTELMAkGA1UEBhMCVVMxFTAT
# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEk
# MCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTA2MTExMDAw
# MDAwMFoXDTIxMTExMDAwMDAwMFowYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERp
# Z2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMY
# RGlnaUNlcnQgQXNzdXJlZCBJRCBDQS0xMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
# MIIBCgKCAQEA6IItmfnKwkKVpYBzQHDSnlZUXKnE0kEGj8kz/E1FkVyBn+0snPgW
# Wd+etSQVwpi5tHdJ3InECtqvy15r7a2wcTHrzzpADEZNk+yLejYIA6sMNP4YSYL+
# x8cxSIB8HqIPkg5QycaH6zY/2DDD/6b3+6LNb3Mj/qxWBZDwMiEWicZwiPkFl32j
# x0PdAug7Pe2xQaPtP77blUjE7h6z8rwMK5nQxl0SQoHhg26Ccz8mSxSQrllmCsSN
# vtLOBq6thG9IhJtPQLnxTPKvmPv2zkBdXPao8S+v7Iki8msYZbHBc63X8djPHgp0
# XEK4aH631XcKJ1Z8D2KkPzIUYJX9BwSiCQIDAQABo4IDejCCA3YwDgYDVR0PAQH/
# BAQDAgGGMDsGA1UdJQQ0MDIGCCsGAQUFBwMBBggrBgEFBQcDAgYIKwYBBQUHAwMG
# CCsGAQUFBwMEBggrBgEFBQcDCDCCAdIGA1UdIASCAckwggHFMIIBtAYKYIZIAYb9
# bAABBDCCAaQwOgYIKwYBBQUHAgEWLmh0dHA6Ly93d3cuZGlnaWNlcnQuY29tL3Nz
# bC1jcHMtcmVwb3NpdG9yeS5odG0wggFkBggrBgEFBQcCAjCCAVYeggFSAEEAbgB5
# ACAAdQBzAGUAIABvAGYAIAB0AGgAaQBzACAAQwBlAHIAdABpAGYAaQBjAGEAdABl
# ACAAYwBvAG4AcwB0AGkAdAB1AHQAZQBzACAAYQBjAGMAZQBwAHQAYQBuAGMAZQAg
# AG8AZgAgAHQAaABlACAARABpAGcAaQBDAGUAcgB0ACAAQwBQAC8AQwBQAFMAIABh
# AG4AZAAgAHQAaABlACAAUgBlAGwAeQBpAG4AZwAgAFAAYQByAHQAeQAgAEEAZwBy
# AGUAZQBtAGUAbgB0ACAAdwBoAGkAYwBoACAAbABpAG0AaQB0ACAAbABpAGEAYgBp
# AGwAaQB0AHkAIABhAG4AZAAgAGEAcgBlACAAaQBuAGMAbwByAHAAbwByAGEAdABl
# AGQAIABoAGUAcgBlAGkAbgAgAGIAeQAgAHIAZQBmAGUAcgBlAG4AYwBlAC4wCwYJ
# YIZIAYb9bAMVMBIGA1UdEwEB/wQIMAYBAf8CAQAweQYIKwYBBQUHAQEEbTBrMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKG
# N2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJv
# b3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9j
# cmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwHQYD
# VR0OBBYEFBUAEisTmLKZB+0e36K+Vw0rZwLNMB8GA1UdIwQYMBaAFEXroq/0ksuC
# MS1Ri6enIZ3zbcgPMA0GCSqGSIb3DQEBBQUAA4IBAQBGUD7Jtygkpzgdtlspr1LP
# UukxR6tWXHvVDQtBs+/sdR90OPKyXGGinJXDUOSCuSPRujqGcq04eKx1XRcXNHJH
# hZRW0eu7NoR3zCSl8wQZVann4+erYs37iy2QwsDStZS9Xk+xBdIOPRqpFFumhjFi
# qKgz5Js5p8T1zh14dpQlc+Qqq8+cdkvtX8JLFuRLcEwAiR78xXm8TBJX/l/hHrwC
# Xaj++wc4Tw3GXZG5D2dFzdaD7eeSDY2xaYxP+1ngIw/Sqq4AfO6cQg7Pkdcntxbu
# D8O9fAqg7iwIVYUiuOsYGk38KiGtSTGDR5V3cdyxG0tLHBCcdxTBnU8vWpUIKRAm
# MYIEOzCCBDcCAQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
# IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNl
# cnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2lnbmluZyBDQQIQBj1zuMh0hjKHysC4
# H/YGkDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU9gd/QFwKB6t5g2dy844FCKr37W8wDQYJKoZI
# hvcNAQEBBQAEggEAaSLJVMhf30t3Fv7CObCB4Mgaz/XuXCCyGwQJn7umlAh57L4s
# LPMbfnZLZAyInWBrQpL8aXJ+Q7h147EvXCQCqIU72Mu2u3orj/imRZOyjiXZv1Ka
# UL37kI4j7RMGjuvPvgy5O+RNXq6mrMbR/oAh9Ntyzci1JzWLdPB3S4bUsX4iLYwg
# 5QI5/IhCwEjC1T+6mxktv9bIaQ23f86dm0DgMalW3+0rmV87T+CwD4DKPora1mkM
# vNPg3RU+wjMOijQ3LadtPrQgPr10WZ8OygEi6goW1iBlJO72blSc4Q392UcqajA8
# vSfajiLoJ7d62aB3ehqr52YuuGZKGACvVf1WkqGCAg8wggILBgkqhkiG9w0BCQYx
# ggH8MIIB+AIBATB2MGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0
# IEFzc3VyZWQgSUQgQ0EtMQIQAwGaAjr/WLFr1tXq5hfwZjAJBgUrDgMCGgUAoF0w
# GAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTkwMjI4
# MjE0MzExWjAjBgkqhkiG9w0BCQQxFgQUvcVRwo5eNTczwCZA6Vh/5FgVoe0wDQYJ
# KoZIhvcNAQEBBQAEggEAXpOvg5jAwo8cwZ3Tca61JWQheoyshbDkB7TQOcPM6TGS
# bYwxTQlOe+rX/5m9KVAFP8VUZMJHZsxuN72zNwbEngd03dyPi4HYbzkxFYnaH/U0
# I1jZTuLjCAiismL0FsISMs1hGYSA5rtJF3hq6eMUulO8Rcd/i8Nb39Gfbg6stCpe
# Xi3g/ahWloCReC5aCMx5l+TcncMK9x0kyAhhHD0Fasz++rT2xPj/AQG7scg/9jcU
# TcaPvQ3Qay1UUfnRd3Ir4NFZaRaUNmG3iPT8FUElbEkibUSV/adQBVc8XFoCPj1T
# UnJIZh6cKYMRmerNK+Zv+XJYaD276cxy+MSWCj96SQ==
# SIG # End signature block
