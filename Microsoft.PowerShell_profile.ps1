Import-Module 'C:\dev\devshell\posh-git\src\posh-git.psd1'

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

Function gctag {
    git -c user.email="v-chbeha@microsoft.com" `
        -c user.name="Chris BeHanna"           `
        tag
}

Function gfpo { git fetch origin --prune }
Function glf  { git lfs fetch }
Function grup { git remote update --prune }

New-Alias -Name mvim -Value gvim

if ($PSVersionTable.PSVersion.Major -ge 7) {
    Remove-Alias rm
}

Function rm {
    Param(
        [Switch]
        $rf = $False,

        [Parameter(ValueFromRemainingArguments)]
        $Remaining)

    if ($rf -Eq $True) {
        Remove-Item -Recurse -Force @Remaining
    }
    else {
        Remove-Item @Remaining
    }
}

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
