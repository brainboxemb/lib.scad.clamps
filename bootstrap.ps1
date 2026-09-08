param(
    [switch] $SkipUpdate
)

$ErrorActionPreference = "Stop"

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Args
    )

    & git @Args
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Args -join ' ') failed with exit code $LASTEXITCODE."
    }
}

$RepoRoot = (& git rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $RepoRoot) {
    throw "Run bootstrap.ps1 from inside the lib.scad.clamps Git repository."
}
$RepoRoot = $RepoRoot.Trim()
Set-Location $RepoRoot

$Path = "tools/tool.scad-project"
$Url = git config -f .gitmodules --get "submodule.tools/tool.scad-project.url"
if (-not $Url) {
    throw "tool.scad-project is missing from .gitmodules."
}

$Entry = git ls-files --stage -- $Path
if ($Entry -notmatch '^160000\s') {
    if (Test-Path $Path) {
        $Children = @(Get-ChildItem -Force $Path -ErrorAction SilentlyContinue)
        if ($Children.Count -eq 0) {
            Remove-Item -Force $Path
        }
        elseif (-not (Test-Path (Join-Path $Path ".git"))) {
            throw "Cannot register $Path because non-Git files already exist there."
        }
    }

    git submodule add --force $Url $Path
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to register $Path."
    }
}

git submodule sync --recursive
if (-not $SkipUpdate) {
    git submodule update --init --recursive
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to initialize submodules."
    }
}

Write-Host ""
Write-Host "Bootstrap complete."
git submodule status --recursive
