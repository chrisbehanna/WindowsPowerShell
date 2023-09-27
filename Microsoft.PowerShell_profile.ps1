Import-Module "$home\.config\posh-git\src\posh-git.psd1"

$env:NEXUS_ROOT = "C:\ProgramData\nexus"

#
# I don't need the full version-fu for PowerShell in WindowTitle, and I don't
# care about 64-bit, either.  In a tabbed console, WindowTitle real estate is
# precious, so abbreviate the WindowTitle suffix to "PS m.n (PID)"
#
$GitPromptSettings.WindowTitle = {param($GitStatus, [bool]$IsAdmin) "$(if ($IsAdmin) {'Admin: '})$(if ($GitStatus) {"$($GitStatus.RepoName) [$($GitStatus.Branch)]"} else {Get-PromptPath}) ~ PS $($PSVersionTable.PSVersion.Major.ToString()).$($PSVersionTable.PSVersion.Minor.ToString()) ($PID)"}

Set-PSReadLineOption -EditMode Vi

function adminsh {
    Start-Process -Verb 'runas' -FilePath (Get-Process -Id $PID).Path
}

Function basename {
    [CmdletBinding()]
    Param(
        [String] $Path
    )

    $p = Get-Item $Path
    Return $p.BaseName
}

Function df {
    [CmdletBinding()]
    Param(
        [Switch] $h    = $false,
        [String] $Path = $pwd
    )

    $p = Get-Item $Path
    Write-Output $p.PSDrive
}

Function dirname {
    [CmdletBinding()]
    Param(
        [String] $Path
    )

    $p = Get-Item $Path
    Return $p.PSParentPath.Split('::')[1]
}

#
# Invoke a "remote" PSSession so that if your terminal window dies, the stuff
# running in the background does not die.  This is not as good as screen or
# tmux, but it's *something*.  This alias creates the session.  You can just use
# Enter-PSSession -Name with the name you gave it to reconnect to it.
#
Function durable {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [String] $Name
    )
    Enter-PSSession -EnableNetworkAccess -Name $Name
}

Function gctag {
    git -c user.email="cbehanna@microsoft.com" `
        -c user.name="Chris BeHanna"           `
        tag
}

Function gfpo { git fetch origin --prune }

Function glf {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [String] $remote = "origin",

        [Parameter(Mandatory=$True)]
        [String] $branch = "main",

        [String] $C = "."
    )
    git -C $C lfs fetch $remote $branch
}

Function grom { git rebase origin/main }

Function grup {
    [CmdletBinding()]
    Param(
        [String] $C = "."
    )
    git -C $C remote update --prune
}

Function gsuir { git submodule update --init --recursive --depth=10 }

New-Alias -Name mvim -Value gvim

New-Alias -Name vs2022      -Value "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
New-Alias -Name vs2022debug -Value "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\VSJITDebugger.exe"

#
# Unix-like "time" command
#
#$thisDir = $(Get-Item $profile).DirectoryName
#$time = Join-Path -Path $thisDir -ChildPath "time.ps1"
#. $time

if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSVersionTable.OS.Contains("Windows")) {
    Remove-Alias rm

    Function rm {
        Param(
            [Switch]
            $rf = $False,

            [Parameter(ValueFromRemainingArguments)]
            $Remaining
        )

        if ($rf -Eq $True) {
            Remove-Item -Recurse -Force @Remaining
        }
        else {
            Remove-Item @Remaining
        }
    }
}

#
# For working around colorization bug when passing
# git ls-remote | sls foo
#
Filter slsne {
    [CmdletBinding()]
    Param(
        [String]
        $Pattern,

        [Parameter(ValueFromPipeline=$true)]
        $PipelineInput
    )

    Begin {}

    Process {
        foreach($i in $PipelineInput) {
            Write-Output [String]$i | Select-String -NoEmphasis -Pattern $Pattern
        }
    }

    End {}
}

#
# WIP
#
Function wc {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline)]
        [String] $str = ""
    )

    # Need to add a sum in here somewhere
    Process {
        $_ | Measure-Object -line -word -character
    }
}

Set-Alias -Name vscode -Value "C:\Program Files\Microsoft VS Code\Code.exe"

#
# Example--useless when posh-git controls the window title.
#
Function xtitle {
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [string]
        $Title
    )

    $Host.UI.RawUI.WindowTitle = $Title
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
