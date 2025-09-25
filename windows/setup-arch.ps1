param(
    [string]$Distro = "archlinux",
    [string]$InstallUrl = "https://gist.githubusercontent.com/minipog/d901176d9bb2275a0f7c801687679d61/raw/1e9b1f1c56627611291565baa9eeefeacff04a61/init-arch.sh"
)

function Step([string]$msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Fail([string]$msg) { Write-Host "✗ $msg" -ForegroundColor Red; exit 1 }

Step "Updating WSL"
wsl --update
if ($LASTEXITCODE -ne 0) { Fail "Failed to update WSL" }

Step "Ensuring WSL platform is installed"
wsl --install --no-distribution

Step "Ensuring WSL distro '$Distro' is installed"
$distros = try { wsl --list --quiet 2>$null } catch { @() }
if (-not ($distros -match "^$Distro$")) {
    Step "Installing $Distro..."
    wsl --install -d $Distro --no-launch
    if ($LASTEXITCODE -ne 0) { Fail "Failed to install $Distro" }
} else {
    Step "Distro '$Distro' already installed"
}

Step "Running install.sh inside '$Distro'"
wsl -d $Distro -- bash -lc "curl -fsSL $InstallUrl | bash"
if ($LASTEXITCODE -ne 0) { Fail "Install script failed inside WSL" }

wsl --shutdown
