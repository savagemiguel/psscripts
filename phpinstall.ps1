# Set PHP version and install location
$phpVersion = "8.4.7"
$phpDownloadUrl = "https://windows.php.net/downloads/releases/php-$phpVersion-nts-Win32-vs17-x64.zip"
$phpInstallDir = "C:\PHP"
$phpDownloadPath = "$env:TEMP\php-$phpVersion.zip"

# SECTION - First check for Admin rights. If user doesn't have admin rights, warn the user and exist script.
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# SECTION - If user is not Admin, warn the user and then prompt them if they want to run script as Admin.
if (-not $isAdmin) {
    Write-Host "ERROR: This script is not running with administrator privileges." -ForegroundColor Red
    $response = Read-Host "Do you want to relaunch this script as an administrator? (y/N)"
    if ($response -match '^(y|Y|yes|YES)$') {
        Write-Host "Relaunching script as an administrator..."
        Start-Sleep -Seconds 2
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    } else {
        Write-Host "ERROR: Administrator privileges are required... exiting."
    }
}

# SECTION - Download PHP zip file if it doesn't exist.
if (-not (Test-Path $phpDownloadPath)) {
    Write-Host "Downloading PHP $phpVersion... please wait."
    Invoke-WebRequest -Uri $phpDownloadUrl -OutFile $phpDownloadPath
}

# SECTION - Create install directory if it doesn't exist
if (-not (Test-Path $phpInstallDir)) {
    Write-Host "Creating PHP install directory... please wait."
    New-Item -ItemType Directory -Path $phpInstallDir | Out-Null
}

# SECTION - Extract PHP zip file to install directory
Write-Host "Extracting PHP $phpVersion... please wait."
Expand-Archive -Path $phpDownloadPath -DestinationPath $phpInstallDir -Force

# SECTION - Add PHP to system PATH ENV variables
$envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($envPath -notlike "*$phpInstallDir*") {
    Write-Host "Adding PHP $phpVersion to system PATH... please wait."
    [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$phpInstallDir", [System.EnvironmentVariableTarget]::Machine)
} else {
    Write-Host "PHP $phpVersion is already in system PATH."
}

Write-Host "PHP $phpVersion installation has completed. Please restart your terminal or log out/in for PATH changes to take effect."
$response = Read-Host "Press Enter to exit."
if ($response -match '^$') {
    Write-Host "Thank you for using this to install PHP."
    Start-Sleep -Seconds 3
}