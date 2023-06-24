Function Connect-WinSCPFTPSession {
<#
.SYNOPSIS
This cmdlet is used to establish the initial WiNSCP authentication and connection for a WinSCP FTP, SFTP, or FTPS server and is required for the rest of the cmdlets in this module to work


.DESCRIPTION
Establish WinSCP connection session to access FTP server. The global variable $Global:WinScpFtpSession gets created by this cmdlet. The WinSCP session may close from a timeout based on the configuration of the server. Otherwise use Disconnect-WinSCPFTPSession


.PARAMETER Protocol
Define the protocol to use when connecting to the WinSCP server

.PARAMETER Server
Define the FTP server hostname, FQDN, or IP Address

.PARAMETER Port
Define the destination port to connect to on the WinSCP server

.PARAMETER Credential
Enter credentials to authenticate to the FTP server

.PARAMETER Username
Enter the username to authenticate to the FTP server with

.PARAMETER Password
Enter the password of the user to authenticate with

.PARAMETER KeyUsername
Enter the username associated with the private key

.PARAMETER SshPrivateKeyPath
Enter the file path to a PPK file containing the private key to authenticate with

.PARAMETER SshPrivateKeyPassPhrase
Define the pass phrase used to protect the private key in the PPK file

.PARAMETER SshHostKeyFingerprint
Define the expected host key of the remote SFTP server. This can be viewed in the connection properies of the WinSCP app or if you connect with Putty for the first time to an SFTP server

.PARAMETER HostKeyPolicy
Define the host key policy for previously unknown host keys

.PARAMETER FTPMode
Define whether to use Active of Passive FTP mode

.PARAMETER FTPEncryption
Define whether to not use encryption or use Implicit or Explicit encryption

.PARAMETER TrustCertificate
Tells your device to trust the FTPS servers SSL certificate

.PARAMETER Timeout
Define the connection timeout to the FTP server

.PARAMETER LogSession
Tells connection to log the session to a file

.PARAMETER LogLevel
Set the debug level for verbosity of your session files logging

.PARAMETER LogPath
Define the location to log session information too

.PARAMETER WinScpDllPath
Define the location of the WinSCP NET Assembly DLL file containing the require .NET Assembly obects


.EXAMPLE
PS> Connect-WinSCPFTPSession -Protocol Sftp -Server 127.0.0.1 -Credential (Get-Credential) -LogSession
# This example logs and uses an FTP over SSH (SFTP) connection with 127.0.0.1 using a credential object. There is a 15 second timeout to connect to the destination server and any new host keys are automatically accepted

.EXAMPLE
PS> Connect-WinSCPFTPSession -Protocol Sftp -Server 127.0.0.1 -KeyUserName admin -SshPrivateKeyPassPhrase (ConvertTo-SecureString -String "Keypassword123!" -AsPlainText -Force) -SshPrivateKeyPath "C:\Users\admin\.ssh\id_rsa.ppk" -Timeout 15 -HostKeyPolicy AcceptNew -WinScpDllPath "C:\ProgramData\WinSCP\WinSCPnet.dll"
# This example uses an FTP over SSH (SFTP) connection with 127.0.0.1 using a password protected SSH key. There is a 15 second timeout to connect to the destination server and any new host keys are automatically accepted

.EXAMPLE
PS> Connect-WinSCPFTPSession -Protocol Ftp -FtpEncryption "Implicit" -Server 127.0.0.1 -Port 990 -HostKeyPolicy Check -FTPMode Passive -HostKeyPolicy Check -LogSession -LogPath "$env:TEMP\Logs\ftp-session.log"
# This example use a passive implicit FTP over SSL (FTPS) connection. There is a 15 second timeout to connect to the destination server and any new host keys will prompt for confirmation. This also logs the session connections to a custom log location

.EXAMPLE
PS> Connect-WinSCPFTPSession -Protocol Ftp -FtpEncryption "Explicit" -Server 127.0.0.1 -Port 21 -Credential (Get-Credential) -FTPMode Active -Timeout 15 -HostKeyPolicy GiveUpSecurityAndAcceptAny
# This example use an acive explicit FTP over SSL (FTPS) connection. There is a 15 second timeout to connect to the destination server and any new host keys will be ignored


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: info@osbornepro.com


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
            HelpMessage="[H] Specify SFTP for an FTP over SSH server or FTP for FTP or FTPS server `n[-] EXAMPLE: Sftp `n[-] EXAMPLE: Ftp `n[-] SELECTION "
        )]  # End Parameter
        [ValidateSet('Sftp','Ftp')]
        [String]$Protocol = "Sftp",

        [Parameter(
            Mandatory=$True,
            HelpMessage="[H] Enter the FQDN, IP address, or hostname of the WinSCP server`n  [-] EXAMPLE: ftp.domain.com "
        )]  # End Parameter
        [String]$Server,

        [Parameter(
            Mandatory=$False,
            HelpMessage="[H] Enter the destination port for the WinSCP server. Setting this value to 0 will use the default port `n  [-] EXAMPLE: 21 "
        )]  # End Parameter
        [ValidateRange(0, 65535)]
        [Int]$Port = 0,

        [Parameter(
            Mandatory=$True,
            ParameterSetName="Credential"
        )]  # End Parameter
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(
            ParameterSetName="Credentials",
            Mandatory=$True,
            HelpMessage="[H] Enter the username to authenticate to the WinSCP server with`n  [-] EXAMPLE: ftpadmin "
        )]  # End Parameter
        [String]$Username,

        [Parameter(
            ParameterSetName="Credentials",
            Mandatory=$True,
            HelpMessage="[H] Enter the password to authenticate to the WinSCP server with for the user specified `n  [-] EXAMPLE: (ConvertTo-SecureString -String 'Password123!' -AsPlainText -Force) `n  [-] EXAMPLE: (Read-Host -Prompt 'Enter password' -AsSecureString) "
        )]  # End Parameter
        [SecureString]$Password,

        [Parameter(
            ParameterSetName="Key",
            Mandatory=$True,
            HelpMessage="[H] Enter the username to authenticate to the WinSCP server with`n  [-] EXAMPLE: ftpadmin "
        )]  # End Parameter
        [String]$KeyUsername,

        [Parameter(
            ParameterSetName="Key",
            Mandatory=$True,
            HelpMessage="[H] Define the location of the .ppk certificate file to authenticate with `n  [-] EXAMPLE: C:\Users\Administrator\.ssh\id_rsa.ppk "
        )]  # End Parameter
        [ValidateScript({$_.Name -like "*.ppk"})]
        [System.IO.FileInfo]$SshPrivateKeyPath,

        [Parameter(
            ParameterSetName="Key",
            Mandatory=$False,
            HelpMessage="[H] Enter the SSH private key password to authenticate to the WinSCP server with `n  [-] EXAMPLE: (ConvertTo-SecureString -String 'Password123!' -AsPlainText -Force) `n  [-] EXAMPLE: (Read-Host -Prompt 'Enter password' -AsSecureString) "
        )]  # End Parameter
        [SecureString]$SshPrivateKeyPassPhrase,

        [Parameter(
            ParameterSetName="Key",
            Mandatory=$False
        )]  # End Parameter
        [String]$SshHostKeyFingerprint = 'ssh-rsa 2048 6Rr0BuqQo1j+sFzR3rm45lAmBAGsZb69tcLGIZf4aP8',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [ValidateSet('AcceptNew','GiveUpSecurityAndAcceptAny','Check')]
        [String]$HostKeyPolicy = "AcceptNew",

        [Parameter(
            ParameterSetName="Credential",
            Mandatory=$False
        )]  # End Parameter
        [Parameter(
            ParameterSetName="Credentials",
            Mandatory=$False
        )]  # End Parameter
        [ValidateSet('Active','Passive')]
        [String]$FTPMode = "Passive",

        [Parameter(
            ParameterSetName="Credential",
            Mandatory=$False
        )]  # End Parameter
        [Parameter(
            ParameterSetName="Credentials",
            Mandatory=$False
        )]  # End Parameter
        [ValidateSet('None','Implicit','Explicit')]
        [String]$FTPEncryption,

        [Parameter(
            ParameterSetName="Credential",
            Mandatory=$False
        )]  # End Parameter
        [Parameter(
            ParameterSetName="Credentials",
            Mandatory=$False
        )]  # End Parameter
        [Switch]$TrustCertificate,

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [Int]$Timeout = 15, # Seconds

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [Switch]$LogSession,

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [ValidateRange(0, 7)]
        [String]$LogLevel = 0,

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$LogPath = "$env:TEMP\Logs\$(Get-Date -Format 'yyyy-MM-dd_hh-mm-ss')_sftp-session-logs.txt",

        [ValidateNotNullOrEmpty()]
        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [ValidateScript({$_.Name -eq "WinSCPnet.dll"})]
        [System.IO.FileInfo]$WinScpDllPath = "$env:ProgramData\WinSCP\WinSCPnet.dll",

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [Switch]$IgnoreReminder,
    )  # End param

BEGIN {

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Loading the WinSCP assembly from $WinScpDllPath"
    If (!(Test-Path -Path $WinScpDllPath.FullName)) { Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') File not foudn: $WinScpDllPath" }
    Try { Add-Type -Path $WinScpDllPath -Verbose:$False -ErrorAction SilentlyContinue } Catch { Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') $WinScpDllPath already a loaded assembly"}

    If ($LogSession.IsPresent) {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Session will be logged to $LogPath"
        New-Item -Path $LogPath -ItemType File -Force -ErrorAction SilentlyContinue -Verbose:$False | Out-Null

    }  # End If

} PROCESS {

    Write-Debug -Message "[d] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') ParameterSetName value is $($PSCmdlet.ParameterSetName)"
    Switch ($PSCmdlet.ParameterSetName) {

        'Credentials' {

            $SessionOptions = New-Object -TypeName WinSCP.SessionOptions -Property @{
                Protocol = [WinSCP.Protocol]::$Protocol;
                PortNumber = $Port;
                HostName = $Server;
                UserName = $Username;
                SecurePassword = $Password;
                FtpMode = [WinSCP.FtpMode]::$FTPMode;
                Timeout = $Timeout;
            }  # End $SessionOptions

        } 'Key' {

            $SessionOptions = New-Object -TypeName WinSCP.SessionOptions -Property @{
                Protocol = [WinSCP.Protocol]::$Protocol;
                PortNumber = $Port;
                HostName = $Server;
                UserName = $KeyUsername;
                SshPrivateKeyPath = $SshPrivateKeyPath.FullName;
                SecurePrivateKeyPassphrase = $SshPrivateKeyPassPhrase;
                Timeout = $Timeout;
            }  # End $SessionOptions

        } 'Credential' {

            $SessionOptions = New-Object -TypeName WinSCP.SessionOptions -Property @{
                Protocol = [WinSCP.Protocol]::$Protocol;
                PortNumber = $Port;
                HostName = $Server;
                UserName = $Credential.Username;
                SecurePassword = $Credential.Password;
                FtpMode = [WinSCP.FtpMode]::$FTPMode;
                Timeout = $Timeout;
            }  # End $SessionOptions

        } Default {

            Throw "[x] Unable to determine a required credential parameter set name for $($PSCmdlet.ParameterSetName)"

        }  # End Switch Options

    }  # End Switch

    $WritePort = $Port
    Switch ($Protocol) {

        'Ftp' {

            $SessionOptions.FtpSecure = $FTPEncryption
            If ($TrustCertificate.IsPresent) {

                $SessionOptions.GiveUpSecurityAndAcceptAnyTlsHostCertificate = 1

            }  # End If

            If ($Port -eq 0 -and $SessionOptions.FtpSecure -like "Implicit") {

                $WritePort = 990

            } ElseIf ($Port -eq 0 -and $SessionOptions.FtpSecure -like "Explicit") {

                $WritePort = 21

            }  # End If ElseIf

        } 'Sftp' {

            If ($PSBoundParameters.ContainsKey('SshHostKeyFingerprint')) {

                Write-Verbose -Message "[V] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Adding host key to Session options"
                $SessionOptions.SshHostKeyFingerprint = $SshHostKeyFingerprint

            } ElseIf ($PSBoundParameters.ContainsKey('HostKeyPolicy')) {

                Write-Verbose -Message "[V] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Adding host key policy to session options"
                $SessionOptions.SshHostKeyPolicy = [WinSCP.SshHostKeyPolicy]::$HostKeyPolicy
    
            }  # End If ElseIf

            If ($Port -eq 0) {

                $WritePort = 22

            }  # End If

        }  # End Switch Options

    }  # End Switch

    $BackDir = $WinScpDllPath.DirectoryName.Split('\')[-1]
    If ($BackDir -notlike "net*") {

        $WinSCPExec = Get-ChildItem -Path $WinScpDllPath.DirectoryName -Filter "WinSCP.exe" -File -Recurse -Force -Verbose:$False

    } Else {

        $WinSCPExec = Get-ChildItem -Path $WinScpDllPath.DirectoryName.Replace("$BackDir","") -Filter "WinSCP.exe" -File -Recurse -Force -Verbose:$False

    }  # End If Else

    If ($LogSession.IsPresent) {

        $Global:WinScpFtpSession = New-Object -TypeName WinSCP.Session -Property @{
            ExecutablePath=$($WinSCPExec.FullName);
            DebugLogLevel=$LogLevel;
            SessionLogPath=$LogPath;
        }  # End $WinScpFtpSession

    } Else {

        $Global:WinScpFtpSession = New-Object -TypeName WinSCP.Session -Property @{
            ExecutablePath=$($WinSCPExec.FullName);
        }  # End $WinScpFtpSession

    }  # End If Else
  
} END {

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Establishing $Protocol session"
    $Global:WinScpFtpSession.Open($SessionOptions)

    If ($IgnoreReminder.IsPresent) {
    
        Write-Warning -Message "[!] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Remeber to disconnect your WinSCP session by using Disconnect-WinScpFtpSession"

    }  # End If

}  # End B P E

}  # End Connect-WinSCPFTPSession
