# Source: https://github.com/joaojmendes/BulkUploadFilesToSharePoint/blob/master/UploadFiles.ps1
# Import files to SharePoint Online Site document library
#  João Mendes - 7/9/2018
# Parameters:
#  Site Url
#  csv File:
#-----------------------------------------
#  
[CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$siteUrl,
        [Parameter(Mandatory = $true)]
        [string]$fileName
    )
#********************
# Run Function
#********************    
function ImportFile {
    

    # Teste if module SharePointPnPPowerShellOnline exists
    if ((Get-Module -ListAvailable -Name SharePointPnPPowerShellOnline) -eq $null) {
        Install-Module SharePointPnPPowerShellOnline -force
    }
    clear-host
    # Teste if file exists
    $results = Test-Path $fileName
    if ($results -eq $false) {
        throw " O Ficheiro $fileName com informação a importar não existe."
        exit 1
    }
    # teste se PC is em pt-PT Culture
    $culture = Get-Culture
    if ($culture.Name -ne "pt-PT"){
        throw " O computador não está com Regional Settings defindo para Portugal, (pt-PT) necessário para a execução da Importação."
        exit 1
    }

    # Define LogFile
    $date = get-date -Format "yyyyMMddhhmmss"
    $logfilename = "FilesNotUpload_ $fileName_$date.log"
    write-output " " 
    add-content  -value " " -path $logfilename
    Add-Content -value "A Importação de Ficheiros começou às  $(Get-date)" -path $logfilename -Encoding Oem
    write-output "A Importação de Ficheiros começou às  $(Get-date)"
    Add-Content  -value "CSV file: $fileName"  -path $logfilename -Encoding UTF8
    write-output "CSV file: $fileName"
    Add-content -value "SharePoint Site: $siteUrl"  -path $logfilename -Encoding UTF8
    Write-Output "SharePoint Site: $siteUrl"
    Add-content -value " "  -path $logfilename -Encoding UTF8
   
    # Get Columns and CSV data 
    $fileDataFile = import-csv -path $fileName -Delimiter ";"
    #Get columns Names from CSV
    $fileCoumns = (Get-Content -Path $fileName | Select-Object -First 1) -split ";"
   # Connect SharePoint Online
    Connect-PnPOnline $siteUrl -ErrorAction Stop
    
    # readfiles from CSV 
    $i = 0
    foreach ($fileData in $fileDataFile) {
        Write-Output "---"
        write-output " Upload file: $i"
        Write-output $fileData
        # Testa se Ficheiro a importar existe
    
        $results = Test-Path $fileData.LocalizacaoAtual
        if ($results -eq $false) {
            $msg = " $(get-date -format "yyyy/MM/dd") - Error - Ficheiro a Importar não encontrado, Path: " + $fileData.LocalizacaoAtual
            Add-content -value  $msg -path $logfilename
            Write-output $msg
        }
        else {
            # Doclib Exist ?
            $doclibExists = get-pnpList $fileData.BibliotecaDestino 
            
            if ($doclibExists -eq $null ) {
                $msg = " $(get-date -format "yyyy/MM/dd") - Error - A Biblioteca  " + $fileData.BibliotecaDestino + " não existe no Site:" + $siteUrl
                Add-content -value  $msg -path $logfilename
                Write-output $msg
            }
            else {
                $fileData.BibliotecaDestino.trim()
                $_libcol = get-pnpfield -List $fileData.BibliotecaDestino.trim()
                # Array objects Hastable com valores de Metadados 
                $values = @{}
                for ($j = 3; $j -lt $fileCoumns.Count; $j++) {
                    $addColumnToValues = $true
                    $_column = $fileCoumns[$j]
                    $_columnValue = $fileData.$_column.trim()
                    $columnDef = $_libcol | Where-Object { $_.InternalName -eq $_column}                
                    if ($columnDef -ne $null) {
                        if ($columnDef.TypeAsString -eq "Lookup") {
                            if ($_columnValue -eq $null) {
                                $addColumnToValues = $false
                            }
                            else {
                                $listId = $columnDef.LookupList
                                $listItem = (Get-PnPListItem -List $listId).FieldValues | Where-Object {$_.Title -eq $_columnValue.trim()}
                                if (  $null -eq $listItem) {
                                    $msg = " $(get-date -format "yyyy/MM/dd") - Error - Loja: " + $_columnValue + " Não existe na lista de Lojas "  
                                    Add-content -value $msg -path $logfilename
                                    Write-Output $msg
                                    $addColumnToValues = $false
                                }
                                else {               
                                    $_columnValue = $listItem.ID
                                    $addColumnToValues = $true
                                }
                            }
                        }
                        # Format Date columns to correct Culture
                        if ($columnDef.TypeAsString -eq "DateTime") {  
                            if ( $_columnValue.trim() -ne $null) {
                                #try convert )
                                $_columnValue = get-date($_columnValue) -format "MM/dd/yyyy" -ErrorAction Continue
                                $addColumnToValues = $true
                            }else{
                                $addColumnToValues = $false
                            }
                        }
                    }
                    # se coluna valida add 
                    if ( $addColumnToValues -eq $true) {
                        $values.add($_column.trim(), $_columnValue)
                    }
                }
                # Upload do ficheiro
                try {
                    $_doclibName = $fileData.BibliotecaDestino 
                    $_contenttype = '"' + $fileData.ContentType + '"'
                    $listCtypes = Get-PnPContentType -List  $_doclibName 
                    foreach ($ct in $listCtypes) {
                        if ($ct.Name -eq $fileData.ContentType) {
                            $_ctype = $ct.Id
                        }
                    }  
                    $ctr = Get-PnPContentType -List $fileData.BibliotecaDestino -Identity $_ctype.StringValue
                    Set-PnPDefaultContentTypeToList -List $fileData.BibliotecaDestino -ContentType $ctr.Name 
                    $added = add-pnpfile -Path $fileData.LocalizacaoAtual -Folder  $_doclibName -Values $values  -Checkout  
                }
                catch {
                    $msg = " $(get-date -format "yyyy/MM/dd") - Erro ao fazer uplaod do ficheiro para o SharePoint Site:" + $siteUrl + " Document Library: " + $fileData.BibliotecaDestino + " , Ficheiro: " + $fileData.LocalizacaoAtual + " Erro:" + $($_.Exception.Message)
                    Add-content -value $msg -path $logfilename
                    Write-Output $msg
                }
                # }
            }
        }

        $i += 1  
    }
    add-content "  " -path $logfilename
    $msg = "--- Fim da Importação as $(get-date) "
    Add-content -value $msg -path $logfilename
    Write-Output $msg  
    # Disconnect-PnPOnline
}
#
### Import Files to SharePoint Site ####
# Main #
ImportFile
 