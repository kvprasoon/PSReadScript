# PSWatcher
PowerShell Script repository for PSWatcher module


#Functions
Watch-PSScript
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
