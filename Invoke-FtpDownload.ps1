Function Invoke-FtpDownload {
<#
.SYNOPSIS
This cmdlet is used to download files from an FTP, FTPS, or FTPES server


.DESCRIPTION
Download files from an FTP, FTPS, or FTPES server


.PARAMETER SourceUri
Define the source URI of the FTP server and file you wish to download

.PARAMETER Destination
Define the file path to download the file too

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
PS> Invoke-FtpDownload -SourceUri ftp://127.0.0.1:21/test.txt -Destination C:\Temp\test.txt
# This example downloads test.txt and saves it in C:\Temp over an FTP passive connection without credentials

.EXAMPLE
PS> Invoke-FtpDownload -SourceUri ftp://127.0.0.1:21/test.txt -Destination C:\Temp\test.txt -UsePassive $True -KeepAlive $False -Credential (Get-Credential)
# This example downloads test.txt and saves it in C:\Temp over an FTP passive connection with credentials

.EXAMPLE
PS> Invoke-FtpDownload -SourceUri ftp://127.0.0.1:21/test.txt -Destination C:\Temp\test.txt -UsePassive $True -KeepAlive $False -UseSSL $True -IgnoreCertificateValidation $True -Credential (Get-Credential)
# This example downloads test.txt and saves it in C:\Temp over an FTPES passive connection with credentials that ignores certificate validation errors


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
https://btpssecpack.osbornepro.com
https://www.powershellgallery.com/profiles/tobor
https://www.hackthebox.eu/profile/52286
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges


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
                HelpMessage="[H] Enter the FTP URL to download a file from `n[EXAMPLE] ftp://localhost:21/test `n[INPUT] "
            )]  # End Parameter
            [String]$SourceUri,

            [Parameter(
                Mandatory=$True,
                HelpMessage="[H] Define the local path to save the file too `n[EXAMPLE] C:\Temp\cert.pem `n[INPUT] "
            )]  # End Parameter
            [String]$Destination,

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
                ParameterSetName="FTPS",
                Mandatory=$False
            )]  # End Parameter
            [Bool]$UseSSL = $True,

            [Parameter(
                ParameterSetName="FTPS",
                Mandatory=$False
            )]  # End Parameter
            [Bool]$IgnoreCertificateValidation = $True,

             [Parameter(
                ParameterSetName="FTPS",
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

    $FileName = $Destination.Split('\')[-1]
    New-Item -Path $Destination.Replace("\$($FileName)", "") -ItemType Directory -Force -Verbose:$False -WhatIf:$WhatIfPreference -ErrorAction SilentlyContinue | Out-Null
    
    If ($UseSSL) {

        Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Enforcing client $TlsVersion usage"
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::$TlsVersion

        If ($IgnoreCertificateValidation) {

            Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Ignoring certificate validation checks"
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }

        }  # End If

    }  # End If

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading $SourceUri to $Destination"
    $DownloadRequest = [System.Net.WebRequest]::Create($SourceUri)
    $DownloadRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
    $DownloadRequest.UseBinary = $UseBinary
    $DownloadRequest.UsePassive = $UsePassive
    $DownloadRequest.EnableSsl = $UseSSL
    $DownloadRequest.KeepAlive = $KeepAlive
    $DownloadRequest.Credentials = $Credential.GetNetworkCredential()

    Try {

        $DownloadResponse = $DownloadRequest.GetResponse()
        $SourceStream = $DownloadResponse.GetResponseStream()

    } Catch {

        Write-Warning -Message "[!] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to return a successful response from the FTP server on $Destination"
        Write-Error -Message "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') $($Error[0].Exception.Message)"

    }  # End Try Catch
    $FileStream = New-Object -TypeName System.IO.FileStream -ArgumentList @($Destination, [IO.FileMode]::Create)
    $ReadBuffer = New-Object -TypeName System.Byte[] -ArgumentList @(1024)

    Try {

        Do {

            $ReadLength = $SourceStream.Read($ReadBuffer, 0, 1024)
            $FileStream.Write($ReadBuffer, 0, $ReadLength)

        } While ($ReadLength -ne 0)

        $FileStream.Dispose()
        $SourceStream.Dispose()
        $DownloadResponse.Dispose()

    } Catch {

        Write-Warning -Message "[!] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to create the file $Destination"
        Write-Error -Message "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') $($Error[0].Exception.Message)"

    } Finally {

        If ($FileStream) { $FileStream.Dispose() }
        If ($SourceStream) { $SourceStream.Dispose() }
        If ($DownloadResponse) { $DownloadResponse.Dispose() }

    }  # End Try Catch Finally

}  # End Function Invoke-FtpDownload
