Function Invoke-WinSCPUpload {
<#
.SYNOPSIS
This cmdlet is used to copy files to an FTP server using WinSCP


.DESCRIPTION
Use WinSCP to copy files to a destination FTP server


.PARAMETER Path
Define the files to copy to the FTP server

.PARAMETER Destination
Define the file path on the FTP server to copy files too

.PARAMETER EnumerateDirectory
Return the list of all files in the destination you specify on the SFTP server


.EXAMPLE
PS> Invoke-WinSCPUpload -Path "C:\Users\Administrator\Documents\importantfile.txt","C:\Users\Administrator\Documents\otherfile2.txt" -Destination "C:\SFTP\Uploads"
# This example copies the importantfile.txt and otherfile2.txt to the WinSCP destination C:\SFTP\Uploads using passive FTP over SSH (SFTP). There is a 15 second timeout to connect to the destination server and any new host keys are automatically accepted

.EXAMPLE
PS> Invoke-WinSCPUpload -Path "C:\Users\Administrator\Documents\importantfile.txt","C:\Users\Administrator\Documents\otherfile2.txt" -Destination "C:\SFTP\Uploads" -EnumerateDirectory
# This example copies the importantfile.txt and otherfile2.txt to the WinSCP destination C:\SFTP\Uploads using passive FTP over SSH (SFTP) and lists the contents of the destination directory. There is a 15 second timeout to connect to the destination server and any new host keys are automatically accepted


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
                HelpMessage="[H] Define all the files you to copy to the WinSCP server `n  [-] EXAMPLE: 'C:\Temp\file1.txt', 'C:\file2.txt' `n[-] SELECTION: "
            )]  # End Parameter
            [String[]]$Path,

            [Parameter(
                Mandatory=$True,
                ValueFromPipeline=$False,
                ValueFromPipelineByPropertyName=$False,
                HelpMessage="[H] Define the destination directory to copy files too on the WinSCP server `n  [-] EXAMPLE: C:\Temp\ `n[-] SELECTION: "
            )]  # End Parameter
            [String]$Destination,

            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [Switch]$EnumerateDirectory
        )  # End param

BEGIN {

    $Output = @()
    If (!($Global:WinScpFtpSession.Opened)) {

        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Your WinSCP session is not open. Use Connect-WinSCPFTPSession to connect"

    }  # End If

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Creating $Destination directory if it does not already exist"
    New-Item -Path $Destination -ItemType Directory -Force -ErrorAction SilentlyContinue -Verbose:$False | Out-Null

} PROCESS {

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Transferring $($Path.Count) files to WinSCP server at $Destination"
    ForEach ($File in $Path) {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Uploading $File to $Destination"
        $Session.PutFiles($File, $Destination).Check()
    
    }  # End ForEach
    
    If ($EnumerateDirectory.IsPresent) {
    
        $Directory = $Session.ListDirectory($Destination)
        $SubDirs = $Directory.Files.FullName
    
        ForEach ($Sub in $SubDirs) {
        
            $Output += $Sub
    
        }  # End ForEach
    
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') $($Output.Count) items returned from $Destination"
    
    }  # End If

} END {

    If ($EnumerateDirectory.IsPresent) {

        Return $Output

    }  # End If

}  # End END

}  # End Function Invoke-WinSCPUpload
