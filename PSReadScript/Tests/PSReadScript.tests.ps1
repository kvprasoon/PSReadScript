$ModulePath = Split-Path -Path $PSScriptRoot -Parent

Get-ChildItem -Path "$ModulePath\Main" -Filter *.ps1 | ForEach-Object -Process {
	. $_.FullName
}

Describe 'Tests for Read-PSFile function' {

	it 'Tests the function Read-PSFile throws error if invalid path is mentioned n' {
		{ Read-PSFile -LookupPath 'InvalidPath' -String 's' } | Should Throw
	}

}

Describe 'Tests for Read-PSScript function' {

	it 'Tests the function Read-PSScript throws error if invalid path is mentioned n' {
		{ Read-PSScript -Script 'InvalidPath' -HighlightLine '4' } | Should Throw
	}

	it 'Tests the function Read-PSScript throws error if sciprt in not .ps1 n' {
		"msgbox 'Test File for PSReadScript module'" | Out-File -FilePath $PSScriptRoot\TestFile.vbs -ErrorAction SilentlyContinue
		{ Read-PSScript -Script '$PSScriptRoot\TestFile.vbs' -HighlightLine '4' } | Should Not Throw
	}


}

Remove-Item -Path $PSScriptRoot\TestFile.vbs -Force -ErrorAction SilentlyContinue