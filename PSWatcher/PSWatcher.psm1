<#

.Synopsis
This cmdlet shows the specified script by adding line numbers and error occurred lines and more details if required.

.Description
This cmdlet shows the specified script by adding line numbers and error occurred lines as per the parameters specified.
This cmdlet has three parameter sets and parameter '-Script' is the only Mandatory parameter.This functionality will 
be handy in case of Administration using console only option to analyse error occurng areas of a script.

.Example
PS C:\> Read-PSScript -Script .\test.ps1

Reads the script and output script as plaintext including line numbers.

.Example
PS C:\> Read-PSScript -Script .\test.ps1 -HighlightLine (1..5).

Reads and outputs the script by highlighting first five lines.

.Example
PS C:\> Read-PSScript -Script .\test.ps1  -ExecuteAndShowBadLineAs Raw

Executes the script as usual and shows the script as text after script execution by highighting errorcaused lines.

.Example
PS C:\> Read-PSScript -Script .\test.ps1 -ExecuteAndShowBadLineAs TextTable

Executes script as usual and shows the Script output,Errors and Error occurred line,Expression,Exception and Message as plain text Table.

.Example
PS C:\> Read-PSScript -Script .\test.ps1 -ExecuteAndShowBadLineAs TextTable -HideError

Execute script as usual and shows the Script output and error details as plain text table by hiding Error occurred.

.Example
PS C:\> Read-PSScript -Script .\test.ps1 -ExecuteAndShowBadLineAs TextTable -HideError -HideOutput

Execures the script as ususal and shows only the error details as plaint text table by hiding script output and error occurred.

#requires -version 3
#>
Function  Read-PSScript
{
[CmdletBinding(DefaultParameterSetName='Default')]
param(
# Accepts the script full path.Should be a .ps1 file
[Parameter(Mandatory,ValueFromPipeline = $true)]
[String]$Script,

# Arguments to pass to the Script.Arguments acts positionally.
[Parameter(ParameterSetName='Execute')]
[ValidateNotNullOrEmpty()]
$Argumentlist,

#Accepts array of integers(Line Numbers) for highlighting the lnies.This is usefull when you have an error saying some problem in a specific line.
[Parameter(ParameterSetName='HighlightLine')]
[Int[]]$HighlightLine,

#Switch parameter.Executes the script passed and shows the error occurred lines after executing.
[Parameter(ParameterSetName='Execute')]
[ValidateSet('Raw','TextTable')]
$ExecuteAndShowBadLineAs,

#Clears error occurred while executing the script.
[Parameter(ParameterSetName='Execute')]
[Switch]$HideError,

#Clears the script output for better visibility of Error details.
[Parameter(ParameterSetName='Execute')]
[Switch]$HideOutput
)

Begin{
    $Script:Output=''
    if( -not( Test-Path -Path $Script ) ){
        Write-Warning -Message "Cannot find file $Script";break     
    }
    elseif( (Get-Item -Path $Script | Select-Object -ExpandProperty Extension) -ne '.ps1' ){
        Write-Error -Message "Scpecified file is not a PowerShell script('.ps1')" -Category InvalidArgument -TargetObject '.ps1 file' ; break
    }

    $Line = 0
    $HighLightingLine = New-Object -TypeName System.Collections.ArrayList
    $HighlightLine | ForEach-Object -Process { $HighLightingLine.Add($_) | Out-Null}
    $ErrorActionPreferenceBak = $ErrorActionPreference
    $ClearIt = {}

    if($HideError.IsPresent){ $ErrorActionPreference = 'SilentlyContinue' }
    Function WriteOutput
    {
    param($Input)
        if(-not $HideOutput.IsPresent){ 
        Write-Host -ForegroundColor Magenta 'Script output starts here .....................'        
        $Input 
        Write-Host -ForegroundColor Magenta 'Script output finishes here ...................'        
        }
    }
}

Process{
    if($PSBoundParameters.ContainsKey('ExecuteAndShowBadLineAs')){
        $Global:Error.Clear()
        if( $PSBoundParameters.ContainsKey('ArgumentList') ){
          $ScriptOut =  & $Script $Argumentlist
            WriteOutput -Input $ScriptOut
        }
        else{
          $ScriptOut = & $Script
            WriteOutput -Input $ScriptOut
        }
            $ErrorDetails=@{}
            $Global:Error |  ForEach-Object -Process{
                                $ErrorDetails.Add( $_.InvocationInfo.ScriptLineNumber , @( $_.CategoryInfo.Reason,$_.Exception.Message ) )
                             }
    }
    $Content = Get-Content -Path $Script
    $ContentLengthDigit = $Content.Length.ToString().ToCharArray() | Measure-Object | Select-Object -ExpandProperty Count #Finding No. Digits in Content Length

    $Script:Output = $Content.GetEnumerator() | ForEach-Object -Process{

        $LineNumber = ++$Line
        $LineNumberDigit = ($LineNumber).ToString().ToCharArray() | Measure-Object | Select-Object -ExpandProperty Count #Finding No. Digits in Current line number
        $TrailingSpace = " " * ($ContentLengthDigit - $LineNumberDigit)

        if($ExecuteAndShowBadLineAs -eq 'Raw'){

                if($ErrorDetails.Count){
                    foreach($BadLine in ( $ErrorDetails.GetEnumerator().Name | Sort-Object ))
                    {
                            if($BadLine -eq $LineNumber){
                                Write-Host "$TrailingSpace$(($LineNumber)):  $_" -ForegroundColor Red ; $ErrorDetails.Remove($LineNumber) ; break
                            }
                            else{
                                Write-Host "$TrailingSpace$(($LineNumber)):  $_" -ForegroundColor Green ; break
                            }
                    }#show Red for Bad lines.
                }
                else{ Write-Host "$TrailingSpace$(($LineNumber)):  $_" -ForegroundColor Green }
        }#If Execute Show Bad line is requested as Raw
        Elseif($ExecuteAndShowBadLineAs -eq 'TextTable'){

                if($ErrorDetails.Count){
                    foreach($BadLine in $ErrorDetails)
                    {
                            if(($BadLine.GetEnumerator().Name | Sort-Object | Select-Object -First 1)  -eq $LineNumber){
                                #Write-Host "$TrailingSpace$(($LineNumber)):  $_" -ForegroundColor Red 
                               [PSCustomObject]@{
                                Line = $LineNumber
                                Expression = $_
                                Exception = [Exception]$BadLine.item($LineNumber)[0]
                                Message = $BadLine.item($LineNumber)[1]
                                }
                                $ErrorDetails.Remove($LineNumber) 
                            }
                    }#show Red for Bad lines.
                }
                #else{ Write-Host "$TrailingSpace$(($LineNumber)):  $_" -ForegroundColor Green }
        }#If Execute Show Bad line is requested as Table
        else{
                if($HighLightingLine){
                    $HighLightingLine.Sort()
                    foreach($RequestedLine in $HighLightingLine)
                    {
                            if($RequestedLine -eq $LineNumber){
                                Write-Host "$TrailingSpace$(($LineNumber)):  $_" -ForegroundColor Yellow ; $HighLightingLine.Remove($RequestedLine) ; break
                            }#show Yellow color for requested lines.
                            else{
                                Write-Host "$TrailingSpace$(($LineNumber)):  $_" -ForegroundColor Green ; break
                            }
                    }
                }#If any line is specified to highlight
                else{ Write-Host "$TrailingSpace$(($LineNumber)):  $_" -ForegroundColor Green }
            }#Default, prints all line
                   
    
    }

}
end{
    $Script:Output #| Format-Table  -Wrap
    $ErrorActionPreference = $ErrorActionPreferenceBak
}
}


Export-ModuleMember -Function Read-PSScript
