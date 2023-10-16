Function Get-FtpChildItem {
<#
.SYNOPSIS
This cmdlet is used to enumerate the contents of a FTP directories recursively or individually


.DESCRIPTION
List the files on an FTP server from a single directory or recursively


.PARAMETER Uri
Define the source URI of the file on an FTP server you wish to download

.PARAMETER FtpServer
Define the hostname, FQDN, or IP address of the FTP server to download files from

.PARAMETER SourceDirectory
Define the directory on the FTP server to download files from

.PARAMETER Recurse
Define whether to obtain files from FTP sub directories

.PARAMETER Port
Define the FTP port to connect too

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
PS> Get-FtpChildItem -FtpServer localhost -SourceDirectory "/" -UseActive $True
# This example enumerates the files in the FTP root directory over an FTP active ASCII connection wihtout credentials

.EXAMPLE
PS> Get-FtpChildItem -FtpServer localhost -SourceDirectory "/" -UseSSL $True
# This example enumerates the files in the FTP root directory only over FTPES passive ASCII connection using TLSv1.2 wihtout credentials

.EXAMPLE
PS> Get-FtpChildItem -FtpServer localhost -SourceDirectory "/" -UseSSL $True -UseBinary $False -UsePassive $True -TlsVersion Tls12 -KeepAlive $False
# This example enumerates the files in the FTP root directory only over FTPES passive ASCII connection using TLSv1.2 wihtout credentials

.EXAMPLE
PS> Get-FtpChildItem -FtpServer localhost -SourceDirectory "/" -UseSSL $True -UseBinary $False -UsePassive $True -TlsVersion Tls12 -KeepAlive $False -IgnoreCertificateValidation $True -Credential (Get-Credential)
# This example enumerates the files in the FTP root directory only over FTPES passive ASCII connection using TLSv1.2 and ignores certificate validation errors and prompts for FTP credentials


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
System.Object[]
#>
    [OutputType([System.Object[]])]
    [CmdletBinding(
        DefaultParameterSetName="FTP"
    )]
        param(
            [Parameter(
                ParameterSetName="Uri",
                Mandatory=$True,
                HelpMessage="[H] Define the URI to the FTP file you wish to download `n[EXAMPLE] ftp://localhost:21/test.txt `n[INPUT]"
            )]  # End Parameter
            [Alias('Server', 'ComputerName')]
            [ValidateScript({$_ -like "ftp://*"})]
            [String]$Uri,

            [Parameter(
                ParameterSetName="FTP",
                Mandatory=$True,
                HelpMessage="`n[H] Define the hostname, FQDN, or IP address of the FTP server. `n[EXAMPLE] ftp.domain.com `n[INPUT] "
            )]  # End Parameter
            [Alias('Server', 'ComputerName')]
            [String]$FtpServer,

            [Parameter(
                ParameterSetName="FTP",
                Mandatory=$False
            )]  # End Parameter
            [String]$SourceDirectory = '/',

            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [Switch]$Recurse,

            [Parameter(
                ParameterSetName="FTP",
                Mandatory=$False
            )]  # End Parameter
            [ValidateRange(1, 65535)]
            [UInt16]$Port = 21,

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

        Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Enforcing client $TlsVersion usage for FTP over SSL for connections"
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::$TlsVersion

        If ($IgnoreCertificateValidation) {

            Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Ignoring certificate validation checks"
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }

        }  # End If

    }  # End If

    Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Building FTP request"
    If ($PSCmdlet.ParameterSetName -eq 'FTP') {

        $SourceUri = "ftp://$($FtpServer):$($Port)/$($SourceDirectory)".Replace('//', '/').Replace('ftp:/', 'ftp://')
    
    } Else {

        $SourceUri = $Uri

    }  # End If Else
    
    $WebRequest = [System.Net.WebRequest]::Create($SourceUri)
    $WebRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails
    $WebRequest.UseBinary = $UseBinary
    $WebRequest.UsePassive = $UsePassive
    $WebRequest.EnableSsl = $UseSSL
    $WebRequest.KeepAlive = $KeepAlive
    If ($Credential) {

        $WebRequest.Credentials = $Credential.GetNetworkCredential()

    }  # End If

    If ($UseSSL) {

        Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Enforcing client TLSv1.2 usage"
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

        If ($IgnoreCertificateValidation) {

            Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Ignoring certificate validation checks"
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }

        }  # End If

    }  # End If

    $GetItems = New-Object -TypeName System.Collections.ArrayList
    Try {

        If ($UseSleepTimer) {

            Start-Sleep -Seconds 5

        }  # End If

        $Response = $WebRequest.GetResponse()
        $ResponseStream = $Response.GetResponseStream()
        $StreamReader = New-Object -TypeName System.IO.StreamReader -ArgumentList @($ResponseStream, 'UTF-8')
        While (!$StreamReader.EndOfStream) {

            $Item = $StreamReader.ReadLine()
            $GetItems.Add($Item) | Out-Null

        }  # End While

    } Catch {

        If ($Error[0].Exception.Message -like "*(550)*") {

            Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Only files can be downloaded. $Item is a directory"

        } ElseIf ($Error[0].Exception.Message -like "*(425)*") {

            Write-Warning -Message "[!] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Too many simultaneous connections. Adding usage of a 5 second sleep timer"
            $UseSleepTimer = $True
            Start-Sleep -Seconds 5
            $Response = $WebRequest.GetResponse()
            $ResponseStream = $Response.GetResponseStream()
            $StreamReader = New-Object -TypeName System.IO.StreamReader -ArgumentList @($ResponseStream, 'UTF-8')
            While (!$StreamReader.EndOfStream) {

                $Item = $StreamReader.ReadLine()
                $GetItems.Add($Item) | Out-Null

            }  # End While

        } Else {

            Write-Error -Message "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') $(($Error[0].Exception).Message)"

        }  # End If Else

    } Finally {

        $StreamReader.Dispose()
        $ResponseStream.Dispose()
        $Response.Dispose()

    }  # End Try Finally

    ForEach ($Item in $GetItems) {

        $ArrayValues = $Item.Split(" ", 9, [StringSplitOptions]::RemoveEmptyEntries)
        $FtpUri = "$($SourceUri)/$($ArrayValues[8])"

        If (($ArrayValues[0][0] -like "d*" -or $Item -like "*<DIR>*") -and $Recurse.IsPresent) {

            Write-Verbose -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Enumerating sub directory $FtpUri"
            New-Object -TypeName PSCustomObject -Property @{
                SourceUri=$FtpUri.Replace('\/', '/').Replace('//', '/').Replace('ftp:/', 'ftp://');
                Destination=$FtpUri.Replace('ftp://','').Replace("$($FtpServer):$($Port)", "").Replace('/\/', '/').Replace('//', '/');
                ItemName=$ArrayValues[8];
                ItemType="Directory";
            }  # End New-Object -Property
            $SubDirResults = Get-FtpChildItem -Uri $FtpUri.Replace('\/', '/').Replace('//', '/').Replace('ftp:/', 'ftp://') -Recurse:$Recurse.IsPresent -UsePassive $UsePassive -UseBinary $UseBinary -KeepAlive $KeepAlive -UseSSL $UseSSL -IgnoreCertificateValidation $IgnoreCertificateValidation -Credential $Credential -Verbose:$VerbosePreference -Debug:$DebugPreference
            $SubDirResults

        } ElseIf ($ArrayValues[0][0] -like "d*" -or $Item -like "*<DIR>*") {

            Write-Debug -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Switch parameter -Recurse was not specified. The $($ArrayValues[8]) Sub directory will not be enumerated"
            New-Object -TypeName PSCustomObject -Property @{
                SourceUri=$FtpUri.Replace('\/', '/').Replace('//', '/').Replace('ftp:/', 'ftp://');
                Destination=$FtpUri.Replace('ftp://','').Replace("$($FtpServer):$($Port)", "").Replace('/\/', '/').Replace('//', '/');
                ItemName=$ArrayValues[8];
                ItemType="Directory";
            }  # End New-Object -Property

        } Else {

            $FileName = $Destination.Split('\')[-1]
            New-Item -Path $Destination.Replace("\$($FileName)", "") -ItemType Directory -Force -Verbose:$False -WhatIf:$WhatIfPreference -ErrorAction SilentlyContinue | Out-Null
    
            New-Object -TypeName PSCustomObject -Property @{
                SourceUri=$FtpUri.Replace('\/', '/').Replace('//', '/').Replace('ftp:/', 'ftp://');
                Destination=$FtpUri.Replace('ftp://','').Replace("$($FtpServer):$($Port)", "").Replace('/\/', '/').Replace('//', '/');
                ItemName=$ArrayValues[8];
                ItemType="File";
            }  # End New-Object -Property

        }  # End If ElseIf Else
    
    }  # End ForEach

}  # End Function Get-FtpChildItem
