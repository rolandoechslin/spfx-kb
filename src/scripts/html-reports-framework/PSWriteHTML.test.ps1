# https://github.com/EvotecIT/PSWriteHTML
# https://github.com/EvotecIT/PSWriteHTML/blob/master/Examples/Example-DashimoStyle/Run-EasyDashboard.ps1
# https://github.com/T0pCyber/hawk
# https://github.com/KelvinTegelaar/CIPP-API
# https://github.com/21bshwjt/pki-polaris
# https://github.com/msp4msps/Security/tree/25fdfb34a97f762ee6af46e70ad9936a0b318cff
# https://github.com/msp4msps/Syncro-Documentation
# https://github.com/shiftnerd/Office365UserLicenseReport/blob/f1ae225b1fab51984b4e67df6a51b5dddb9530e1/emaillicensereport-cleaned.ps1
# https://github.com/EvotecIT/O365Essentials/blob/ab07bdd1c7c7179868ee23cee9bcf62d15b3d11f/COMMANDS.MD
# https://github.com/EvotecIT/PSTeams
# https://evotec.xyz/office-365-health-service-using-powershell/

Install-Module -Name PSWriteHTML

$Process = Get-Process | Select-Object -First 5
$Process1 = Get-Process | Select-Object -First 5
$Process2 = Get-Process | Select-Object -First 5
$Process3 = Get-Process | Select-Object -First 5

Dashboard -Name 'Dashimo Test' -FilePath $PSScriptRoot\Output\DashboardEasy.html -Show {
    Tab -Name 'First tab' {
        Section -Name 'Test' {
            Table -DataTable $Process -Filtering
        }
        Section -Name 'Test2' -Collapsable -Collapsed {
            Panel {
                Table -DataTable $Process1
            }
            Panel {
                Table -DataTable $Process1
            }
        }
        Section -Name 'Test3' {
            Table -DataTable $Process -DefaultSortColumn 'Id'
        }
    }
    Tab -Name 'second tab' {
        Panel {
            Table -DataTable $Process2
        }
        Panel {
            Table -DataTable $Process2
        }
        Panel {
            Table -DataTable $Process3 -DefaultSortIndex 4 -ScrollCollapse
        }
    }
} -Online