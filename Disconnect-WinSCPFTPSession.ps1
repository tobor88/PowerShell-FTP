Function Disconnect-WinSCPFTPSession {
<#
.SYNOPSIS
This cmdlet is used to disconnect an established WinSCP FTP session created by Connect-WinScpFtpSession


.DESCRIPTION
Disconnects a WinSCP session to an FTP server created by Connect-WinScpFtpSession using the global variable $Global:WinScpFtpSession


.EXAMPLE
PS> Disconnect-WinSCPFTPSession
# This example disconnects a created WinSCP FTP session


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
None


.OUTPUTS
System.String
#>
    [OutputType([System.String])]
    [CmdletBinding()]
        param()  # End param

    If ($Global:WinSCPFTPSession.Opened -eq $True) {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Disposing of WinSCP Session"
        $Global:WinScpFtpSession.Dispose()
        $Output = "Successfully closed session"

    } Else {

        $Global:WinScpFtpSession.Dispose()
        $Output = "Session no longer open. WinSCP FTP session may have timed out or already been closed"

    }  # End If Else

    Return $Output

}  # End Disconnect-WinSCPFTPSession
