# Getting PSReadScript Main Functions which are in Standalone Scripts
$MainScript = Get-ChildItem -Path "$PSScriptRoot\Main\*.ps1" -ErrorAction SilentlyContinue


Foreach ($Function in $MainScript) {
    try {
        # Functions are loaded here
        . $Function.FullName
    }
    Catch {
        Write-Error -Message "Failed to Import function $($Function.Fullname)"
    }
}




Export-ModuleMember -Function $MainScript.BaseName -Alias 'finn', 'rpf', 'rps', 'fps' -Verbose