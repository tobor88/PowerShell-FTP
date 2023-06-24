Function Invoke-WinSCPDownload {
<#
.SYNOPSIS
This cmdlet is used to copy files to an FTP server using WinSCP


.DESCRIPTION
Use WinSCP to copy files to a destination FTP server


.PARAMETER LocalPath
Define the location to copy files too

.PARAMETER RemotePath
Define the file path on the FTP server to download files from

.PARAMETER EnumerateDirectory
Return the list of all files in the destination you specify on the FTP server


.EXAMPLE
PS> Invoke-WinSCPDownload -LocalPath $env:TEMP -RemotePath @("Test/", "Dev/")
# This example downloads the contents of Test/ and Dev/ on the FTP server to $env:TEMP

.EXAMPLE
PS> Invoke-WinSCPDownload -LocalPath $env:TEMP -RemotePath @("Test/", "Dev/") -EnumerateDirectory
# This example downloads the contents of Test/ and Dev/ on the FTP server to $env:TEMP and outputs a list of all the files that were copied from the FTP server


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.LINK
https://github.com/tobor88
https://github.com/osbornepro
https://www.powershellgallery.com/profiles/tobor
https://osbornepro.com
https://writeups.osbornepro.com
https://encrypit.osbornepro.com
https://btpssecpack.osbornepro.com
https://www.powershellgallery.com/profiles/tobor
https://www.hackthebox.eu/profile/52286
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges


.INPUTS
System.String[]


.OUTPUTS
System.String[]
#>
    [OutputType([System.String[]])]
    [CmdletBinding()]
        param(
            [Parameter(
                Mandatory=$True,
                ValueFromPipeline=$False,
                ValueFromPipelineByPropertyName=$False,
                HelpMessage="[H] Define where to save your files too `n  [-] EXAMPLE: 'C:\Temp\file1.txt', 'C:\file2.txt' `n[-] SELECTION: "
            )]  # End Parameter
            [String]$LocalPath,

            [Parameter(
                Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$False,
                HelpMessage="[H] Define where to download files from on the WinSCP server `n  [-] EXAMPLE: C:\Temp\ `n[-] SELECTION: "
            )]  # End Parameter
            [String[]]$RemotePath,

            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [Switch]$EnumerateDirectory,

            [Parameter(
                Mandatory=$False,
                ValueFromPipeline=$False,
                ValueFromPipelineByPropertyName=$False
            )]  # End Parameter
            [ValidateSet('Binary','Text')]
            [String]$TransferMode = "Binary"
        )  # End param

BEGIN {

    $Output = @()
    If (!($Global:WinScpFtpSession.Opened)) {

        Throw "[x] Your WinSCP session is not open. Use Connect-WinSCPFTPSession to connect"

    }  # End If
 
} PROCESS {

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Setting Transfer options to use $TransferMode"
    $TransferOptions = New-Object -TypeName WinSCP.TransferOptions 
    $TransferOptions.TransferMode = [WinSCP.TransferMode]::$TransferMode

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Transferring files from FTP server to $LocalPath"
    $TransferResult = $Global:WinScpFtpSession.GetFiles("$RemotePath/*", "$LocalPath\*", $False, $TransferOptions)
    $TransferResult.Check() 

    ForEach ($TResult in $TransferResult) {

        $Output += $TResult.Transfers.FileName
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Download of $($TResult.Transfers.FileName) succeeded"

    }  # End ForEach

} END {

    If ($EnumerateDirectory.IsPresent) {

        Return $Output

    }  # End If

}  # End B P E

}  # End Function Invoke-WinSCPDownload
