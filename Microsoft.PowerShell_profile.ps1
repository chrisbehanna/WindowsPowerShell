Import-Module 'C:\dev\devshell\posh-git\src\posh-git.psd1'

#
# I don't need the full version-fu for PowerShell in WindowTitle, and I don't
# care about 64-bit, either.  In a tabbed console, WindowTitle real estate is
# precious, so abbreviate the WindowTitle suffix to "PS m.n (PID)"
#
$GitPromptSettings.WindowTitle = {param($GitStatus, [bool]$IsAdmin) "$(if ($IsAdmin) {'Admin: '})$(if ($GitStatus) {"$($GitStatus.RepoName) [$(GitStatus.Branch)]"} Else {Get-PromptPath}) ~ PS $($PSVersionTable.PSVersion.Major.ToString()).$($PSVersionTable.PSVersion.Minor.ToString()) ($PID)"}

Set-PSReadLineOption -EditMode Vi

Function gfpo { git fetch origin --prune }

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
