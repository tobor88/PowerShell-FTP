# WinSCP-FTP
Collection of PowerShell cmdlets that can be used to interact with a WinSCP FTP server. This supports FTP over SSH, FTP over SSL (Implicit or Explicit), and plain FTP connections.

## How To Use
You first need to establish a WinSCP session using Connect-WinScpFTPSession. This takes a little time to complete and makes executing the other commands much faster when you have a few actions you want to take. When you are done you will want to use Disconnect-WinScpFtpSession to close the connection.

# Cmdlet List
1. Connect-WinScpFtpSession *Connect to a WinSCP FTP session*
2. Disconnect-WinScpFtpSession *Disconnect your WinSCP FTP Session*
3. Get-WinScpChildItem *Enumerate the contents of an FTP servers directory*
4. Invoke-WinScpDownload *Download files from a WinSCP FTP Server*
5. Invoke-WinScpUpload *Upload files from a WinSCP FTP Server*
