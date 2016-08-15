<#
.Synopsis
This cmdlet shows the specified script by adding line numbers and error occured lines and more details if required.
.Description
This cmdlet shows the specified script by adding line numbers and error occured lines as per the parameters specified.
This cmdlet has three parameter sets and parameter '-Script' is the only Mandatory parameter.This functionality will 
be handy in case of Administration using consol only option to analyse error occurng areas of a script.
.Example
PS C:\> Watch-PSScript -Script .\test.ps1

Reads the script and output script as plaintext including line numbers.

.Example
PS C:\> Watch-PSScript -Script .\test.ps1 -HighlightLine (1..5).

Reads and outputs the script by highlighting first five lines.

.Example
PS C:\> Watch-PSScript -Script .\test.ps1  -ExecuteAndShowBadLineAs Raw

Executes the script as usual and shows the script as text after script execution by highighting errorcaused lines.

.Example
PS C:\> Watch-PSScript -Script .\test.ps1 -ExecuteAndShowBadLineAs TextTable

Executes script as usual and shows the Script output,Errors and Error occured line,Expression,Exception and Message as plain text Table.

.Example
PS C:\> Watch-PSScript -Script .\test.ps1 -ExecuteAndShowBadLineAs TextTable -HideError

Execute script as usual and shows the Script output and error details as plain text table by hiding Error occured.

.Example
PS C:\> Watch-PSScript -Script .\test.ps1 -ExecuteAndShowBadLineAs TextTable -HideError -HideOutput

Execures the script as ususal and shows only the error details as plaint text table by hiding script output and error occured.

#>
Function  Watch-PSScript
{
[CmdletBinding(DefaultParameterSetName='Default')]
param(
# Accepts the script full path.Should be a .ps1 file
[Parameter(Mandatory,ValueFromPipeline = $true)]
[ValidatePattern('.ps1')]
[String]$Script,

# Arguments to pass to the Script.Arguments acts positionally.
[Parameter(ParameterSetName='Execute')]
[ValidateNotNullOrEmpty()]
$Argumentlist,

#Accepts array of integers(Line Numbers) for highlighting the lnies.This is usefull when you have an error saying some problem in a specific line.
[Parameter(ParameterSetName='HighlightLine')]
[Int[]]$HighlightLine,

#Switch parameter.Executes the script passed and shows the error occured lines after executing.
[Parameter(ParameterSetName='Execute')]
[ValidateSet('Raw','TextTable')]
$ExecuteAndShowBadLineAs,

#Clears error occured while executing the script.
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
    $Line=0
    $HighLightingLine = New-Object -TypeName System.Collections.ArrayList
    $HighlightLine | ForEach-Object -Process { $HighLightingLine.Add($_)|Out-Null}
    $ErrorActionPreferenceBak = $ErrorActionPreference
    $ClearIt = {}
    if($HideError.IsPresent){ $ErrorActionPreference = 'SilentlyContinue' }
    if($HideOutput.IsPresent){ $ClearIt='Clear-Host' }
}

Process{
    if($PSBoundParameters.ContainsKey('ExecuteAndShowBadLineAs')){

        $Global:Error.Clear()
        Write-Host -ForegroundColor Magenta 'Script output starts .....................'
        if( $PSBoundParameters.ContainsKey('ArgumentList') ){
            & $Script $Argumentlist
        }
        else{
            & $Script
        }
        Write-Host -ForegroundColor Magenta 'Script output finishes ...................'
            $ErrorDetails=@{}
            $Global:Error |  ForEach-Object -Process{ $ErrorDetails.Add( $_.InvocationInfo.ScriptLineNumber , @( $_.CategoryInfo.Reason,$_.Exception.Message ) ) }
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
                    }#show Yellow Red for Bad lines.
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
                                Exception = $BadLine.item($LineNumber)[0]
                                Message = $BadLine.item($LineNumber)[1]
                                }
                                $ErrorDetails.Remove($LineNumber) 
                            }
                    }#show Yellow Red for Bad lines.
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
end
{
    & $ClearIt          
    $Script:Output | Format-Table  -Wrap
    $ErrorActionPreference = $ErrorActionPreferenceBak
}
}


Export-ModuleMember -Function Watch-PSScript -Variable *
