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

## Examples
**Connect-WinSCPFTPSession Examples** 

```powershell
PS> Connect-WinSCPFTPSession -Protocol Sftp -Server 127.0.0.1 -Credential (Get-Credential) -LogSession
# This example logs and uses an FTP over SSH (SFTP) connection with 127.0.0.1 using a credential object. There is a 15 second timeout to connect to the destination server and any new host keys are automatically accepted

PS> Connect-WinSCPFTPSession -Protocol Sftp -Server 127.0.0.1 -KeyUserName admin -SshPrivateKeyPassPhrase (ConvertTo-SecureString -String "Keypassword123!" -AsPlainText -Force) -SshPrivateKeyPath "C:\Users\admin\.ssh\id_rsa.ppk" -Timeout 15 -HostKeyPolicy AcceptNew -WinScpDllPath "C:\ProgramData\WinSCP\WinSCPnet.dll"
# This example uses an FTP over SSH (SFTP) connection with 127.0.0.1 using a password protected SSH key. There is a 15 second timeout to connect to the destination server and any new host keys are automatically accepted

PS> Connect-WinSCPFTPSession -Protocol Ftp -FtpEncryption "Implicit" -Server 127.0.0.1 -Port 990 -HostKeyPolicy Check -FTPMode Passive -HostKeyPolicy Check -LogSession -LogPath "$env:TEMP\Logs\ftp-session.log"
# This example use a passive implicit FTP over SSL (FTPS) connection. There is a 15 second timeout to connect to the destination server and any new host keys will prompt for confirmation. This also logs the session connections to a custom log location

PS> Connect-WinSCPFTPSession -Protocol Ftp -FtpEncryption "Explicit" -Server 127.0.0.1 -Port 21 -Credential (Get-Credential) -FTPMode Active -Timeout 15 -HostKeyPolicy GiveUpSecurityAndAcceptAny
# This example use an acive explicit FTP over SSL (FTPS) connection. There is a 15 second timeout to connect to the destination server and any new host keys will be ignored
```

**DisConnect-WinSCPFTPSession Examples**
```powershell
Disconnect-WinSCPFTPSession
```

**DisConnect-WinSCPFTPSession Examples**
```powershell
PS> Disconnect-WinSCPFTPSession
# This exmaple disconnects a WinSCP FTP Session using the $Global:WinSCPFTPSession variable which is created by Connect-WinSCPFTPSession
```

**Get-WinSCPChildItem Examples**
```powershell
PS> Get-WinSCPChildItem -RemotePath "Test/"
# This example enumerates the contents of the Test directory on a WinSCP FTP server

PS> Get-WinSCPChildItem -RemotePath "Test/" -Recurse
# This example recursively enumerates the contents of the Test directory on a WinSCP FTP server.
# THIS DOES NOT WORK YET
```

**Invoke-WinSCPDownload Examples**
```powershell
PS> Invoke-WinSCPDownload -LocalPath "$env:USERPROFILE\Downloads" -RemotePath @("Test/","Dev/")
# This example downloads the contents of Dev/ and Test/ on the FTP server to $env:USERPROFILE\Downloads on the local machine

PS> Invoke-WinSCPDownload -LocalPath "$env:USERPROFILE\Downloads" -RemotePath @("Test/","Dev/") -EnumerateDirectory
# This example downloads the contents of Dev/ and Test/ on the FTP server to $env:USERPROFILE\Downloads on the local machine and enumerates the contents of the directories
```

**Invoke-WinSCPUpload Examples**
```powershell
PS> Invoke-WinSCPUpload -Path "C:\Users\Administrator\Documents\importantfile.txt","C:\Users\Administrator\Documents\otherfile2.txt" -Destination "C:\SFTP\Uploads"
# This example copies the importantfile.txt and otherfile2.txt to the WinSCP destination C:\SFTP\Uploads using passive FTP over SSH (SFTP). There is a 15 second timeout to connect to the destination server and any new host keys are automatically accepted

PS> Invoke-WinSCPUpload -Path "C:\Users\Administrator\Documents\importantfile.txt","C:\Users\Administrator\Documents\otherfile2.txt" -Destination "C:\SFTP\Uploads" -EnumerateDirectory
# This example copies the importantfile.txt and otherfile2.txt to the WinSCP destination C:\SFTP\Uploads using passive FTP over SSH (SFTP) and lists the contents of the destination directory. There is a 15 second timeout to connect to the destination server and any new host keys are automatically accepted
```
