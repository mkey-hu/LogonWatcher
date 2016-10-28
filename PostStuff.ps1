<#
.Synopsis
   Post-Stuff gets all the stuff it receives via pipeline concat it, and send POST it to an URL. 
.DESCRIPTION
   Post-Stuff gets all the stuff it receives via pipeline concat it, and send POST it to an URL.
   The purpose of this tool is to get PowerShell command output remotely.
   Parameters:
        Stuff - should come from the pipe
        URL - URL to send the data to.
.EXAMPLE
   SomePScommand | Post-Stuff -URL http://someserver/upload-handler 
#>
function Post-Stuff
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        $Stuff,
        
        [string][Parameter (Mandatory=$true)] $URL,
        [string][ValidateSet('Unicode','Ascii')] $Encoding = "Ascii" 
    )

    Begin
    {
        $data=""
    }
    Process
    {
        $data+="$Stuff`n"
    }
    End
    {
        if ($Encoding -eq "Unicode") {$bytes = [System.Text.Encoding]::Unicode.GetBytes($data)}
        else {$bytes = [System.Text.Encoding]::Ascii.GetBytes($data)}
        (new-object Net.WebClient).UploadData($URL,$bytes)
    }
}