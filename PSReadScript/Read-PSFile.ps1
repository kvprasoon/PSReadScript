<#

.Synopsis
This cmdlet shows the specified string in all the sripts including line numbers.

.Description
This cmdlet shows the specified Script by adding line numbers,by default it will search in current directory for
.ps1 script and shows the occurence with line numbers for each file with file name.

.Example
PS C:\> Read-PSFile -LookupPath c:\Scripts -String 'PowerPlan'

Reads all .ps1 scripts and output occurance of the string 'PowerPlan' in all files

.Example
PS C:\> Read-PSFile -LookupPath c:\Scripts -Recurse -String 'PowerShell'

Reads and outputs with line numbers and the line of occurence of the string 'Powershell' for each .ps1 file by recursing into subdirectories

.Example
PS C:\> Read-PSFile -LookupPath -Type '.xml' -String 'Schema'

Reads all .ml files under -path c:\Files and outputs the occurence of the -String 'Schema' in all .xml files with filename

#requires -version 3
#>
Function Read-PSFile
{
Param(
#String to Find inside the file
[Parameter(Mandatory , Position = 0)]
[String]$String,

#Path to search the file
[Parameter(Position = 1)]
[String]$LookupPath = '.',

#Type of the file (extension)
[Parameter(Position = 2)]
[String]$Type = '.ps1',

#Recurse option
[Switch]$Recurse
)

Process{

$String = $String.Replace('\','\\')

Get-ChildItem -Path $LookupPath -File -Filter "*$Type" -Recurse:($Recurse.IsPresent) -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName |
    ForEach-Object -Process {
    if(Get-Content $_ | Select-String -Pattern $String)
    {
        Write-Host -ForegroundColor Green "`n$_"
        Write-Host -ForegroundColor Green ('=' * ($Host.UI.RawUI.WindowSize.width))
        $Count = 0
        Get-Content $_ | ForEach-Object -Process {
                $Count++
                [String]$In = $_ | Select-String -Pattern $String
                if($In)
                {
                    if($PSVersionTable.PSVersion.Major -ge 5)
                    {
                        Write-Host "$Count" -ForegroundColor Magenta -NoNewline
                        Write-Host ": $($In.Trim())"
                    }
                    else
                    {
                        Write-Host "$Count : $($In.Trim())"
                    }
                }

                }
        }
    }

}
}