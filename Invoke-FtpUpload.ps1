Function Invoke-FtpUpload {
<#
.SYNOPSIS
This cmdlet is used to upload files to an FTP, FTPS, or FTPES server


.DESCRIPTION
Upload files from an FTP, FTPS, or FTPES server


.PARAMETER Path
Define the path of the local file you wish to upload to the FTP server

.PARAMETER Destination
Define the FTP directory you wish to upload the file too

.PARAMETER UsePassive
Define whether to use Passive or Active FTP mode

.PARAMETER UseBinary
Define whether to use binary image transfers. Default is ASCII method

.PARAMETER KeepAlive
Define whether a keep alive timer should be used to keep the FTP control connection active

.PARAMETER UseSSL
Define the use of FTP over SSL with your connection

.PARAMETER IgnoreCertificateValidation
Ignore invalid certificate warnings

.PARAMETER TlsVersion
Define the version of TLS to use

.PARAMETER Credential
Define the FTP credentials to authenticate with


.EXAMPLE
PS> Invoke-FtpUpload -Path C:\Temp\test.txt -Destination "/"
# This example uploads test.txt and saves it in the FTP root directory using a passive connection without credentials

.EXAMPLE
PS> Invoke-FtpUpload -Path C:\Temp\test.txt -Destination "/" -UsePassive $True -KeepAlive $False -Credential (Get-Credential)
# This example downloads test.txt and saves it in to the FTP root directory over a passive connection with credentials

.EXAMPLE
PS> Invoke-FtpUpload -Path C:\Temp\test.txt -Destination "/" -UsePassive $True -KeepAlive $False -UseSSL $True -IgnoreCertificateValidation $True -Credential (Get-Credential)
# This example uploads test.txt and saves it in to the FTP root directory over a passive connection with credentials that ignores certificate validation errors


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.LINK
https://osbornepro.com
https://writeups.osbornepro.com
https://encrypit.osbornepro.com
https://btpssecpack.osbornepro.com
https://github.com/tobor88
https://github.com/OsbornePro
https://gitlab.com/tobor88
https://www.powershellgallery.com/profiles/tobor
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges
https://www.hackthebox.eu/profile/52286


.INPUTS
None


.OUTPUTS
None
#>
    [CmdletBinding(
        SupportsShouldProcess=$True,
        ConfirmImpact="Medium"
    )]  # End CmdletBinding
        param(
            [Parameter(
                Mandatory=$True,
                HelpMessage="`n[H] Define the hostname, FQDN, or IP address of the FTP server. `n[EXAMPLE] ftp.domain.com `n[INPUT] "
            )]  # End Parameter
            [Alias('Server')]
            [String]$FtpServer,

            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [UInt16]$Port = 21,

            [Parameter(
                Mandatory=$True,
                HelpMessage="[H] Define the file you wish to upload to the FTP server `n[EXAMPLE] C:\Temp\test.txt `n[INPUT] "
            )]  # End Parameter
            [System.IO.FileInfo]$FilePath,

            [Parameter(
                Mandatory=$False,
                HelpMessage="[H] Define the FTP directory to save the file too `n[EXAMPLE] /Testing `n[INPUT] "
            )]  # End Parameter
            [String]$Destination = "/",

            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [Bool]$UsePassive = $True,

            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [Bool]$UseBinary = $False,

            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [Bool]$KeepAlive = $False,

            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [Bool]$UseSSL = $True,

            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [Bool]$IgnoreCertificateValidation = $True,

             [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [ValidateSet('Ssl3','Tls','Tls11','Tls12','Tls12','SystemDefault')]
            [String]$TlsVersion = "Tls12",

            [ValidateNotNull()]
            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]
            $Credential = [System.Management.Automation.PSCredential]::Empty
        )  # End param

    If ($UseSSL) {

        Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Enforcing client $TlsVersion usage"
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::$TlsVersion

        If ($IgnoreCertificateValidation) {

            Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Ignoring certificate validation checks"
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }

        }  # End If

    }  # End If

    $DestinationUri = "ftp://$($FtpServer):$($Port)$($Destination)$($FilePath.Name)"

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Uploading $($FilePath.FullName) to $DestinationUri"
    $UploadRequest = [System.Net.FtpWebRequest]::Create($DestinationUri)
    $UploadRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $UploadRequest.UseBinary = $UseBinary
    $UploadRequest.UsePassive = $UsePassive
    $UploadRequest.EnableSsl = $UseSSL
    $UploadRequest.KeepAlive = $KeepAlive
    $UploadRequest.Credentials = $Credential.GetNetworkCredential()
    Try {
            
        $FileContents = Get-Content -Path $FilePath.FullName -Encoding Byte -Verbose:$False

    } Catch {

        $FileContents = Get-Content -Path $FilePath.FullName -AsByteStream -Verbose:$False

    }  # End Try Catch
    $UploadRequest.ContentLength = $FileContents.Length

    Try {

        $FtpStream = $UploadRequest.GetRequestStream()
        $FtpStream.Write($FileContents, 0, $FileContents.Length)
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Uploading $($FileContents.Length) bytes to FTP server, please wait..."
        Do {
        
            Try {
    
                $UploadRequest.GetRequestStream()
                $Done = $True
    
            } Catch {
    
                Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Upload still in progress"
                Start-Sleep -Seconds 3
    
            }  # End Try Catch
    
        } Until ($Done)  # End Do
        
        $FtpStream.Dispose()

    } Catch {

        Write-Warning -Message "[!] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to return a successful response from the FTP server on $Destination"
        Write-Error -Message "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') $($Error[0].Exception.Message)"

    }  # End Try Catch

}  # End Function Invoke-FtpUpload
