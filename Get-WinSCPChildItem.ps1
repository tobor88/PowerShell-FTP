Function Get-WinSCPChildItem {
<#
.SYNOPSIS
This cmdlet is used to enumerate the contents of a WinSCP FTP server directory


.DESCRIPTION
Use WinSCP to enumerate files and directories in a remote destination FTP server


.PARAMETER RemotePath
Define the file path on the FTP server to download files from

.PARAMETER Recurse
Recursively enumerate all files in a directory. This is not working yet


.EXAMPLE
PS> Get-WinSCPChildItem -RemotePath "Test/"
# This example enumerates the contents of the Test directory on a WinSCP FTP server

.EXAMPLE
PS> Get-WinSCPChildItem -RemotePath "Test/" -Recurse
# This example recursively enumerates the contents of the Test directory on a WinSCP FTP server


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
[CmdletBinding(DefaultParameterSetName="Credential")]
    param(
        [Parameter(
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$False,
            HelpMessage="[H] Define where to download files from on the WinSCP server `n  [-] EXAMPLE: C:\Temp\ "
        )]  # End Parameter
        [String[]]$RemotePath,

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [Switch]$Recurse
    )  # End param

BEGIN {

    $Output = @()
    If (!($Global:WinScpFtpSession.Opened)) {

        Throw "[x] Your WinSCP session is not open. Use Connect-WinSCPFTPSession to connect"

    }  # End If

} PROCESS {

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Enumerating files from connect FTP server"
    ForEach ($RP in $RemotePath) {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Directory contents of $RP"
        If ($Recurse.IsPresent) {

            Write-Warning -Message "[!] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') I have not discovered how to make recurse work yet"
            $Output += $Global:WinScpFtpSession.ListDirectory("$RP*")

        } Else {

            $Output += $Global:WinScpFtpSession.ListDirectory($RP)

        }  # End If Else

    }  # End ForEach

} END {

    If ($Output) {

        Return $Output.Files

    }  # End If

}  # End B P E

}  # End Function Get-WinSCPChildItem
