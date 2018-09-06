# allow installers to execute
Set-ExecutionPolicy -Force Bypass

If ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
    $programFilesX86= ${env:ProgramFiles(x86)}
} Else {
    $programFilesX86= $env:ProgramFiles
}

# no sleeping
powercfg -change -monitor-timeout-ac 0
powercfg -change -monitor-timeout-dc 0
powercfg -change -standby-timeout-ac 0
powercfg -change -standby-timeout-dc 0

# no windows updates
Stop-Service -Force -NoWait -Name wuauserv
set-service wuauserv -startup disabled
get-wmiobject win32_service -filter "name='wuauserv'"

# set strong cryptography on 32 bit .Net Framework (version 4 and above)
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
# set strong cryptography on 64 bit .Net Framework (version 4 and above)
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord 

# install chocolatey package manager
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
echo $env:ChocolateyInstall
Add-Content $profile 'Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1'
Import-Module $profile
Update-SessionEnvironment

# gnu win32 (ls, rm, sort, and friends)
choco install -y gnuwin32-coreutils.install 
$env:Path= "$programFilesX86\GnuWin32\bin;$env:Path"
[Environment]::SetEnvironmentVariable("Path", "$env:Path", "Machine")
refreshenv

# other tools
choco install -y diffutils fd 7zip.install zip unzip which
which diff
which fd
which sort

# regdiff (sadly not in choco)
$regdiffName="regdiff-4.3"
$regdiffArchive="$regdiffName.7z"
$regdiffArchivePath="C:\Windows\Temp\$regdiffArchive"
$regdiffUrl="http://p-nand-q.com/download/$regdiffArchive"
echo $regdiffUrl
(New-Object System.Net.WebClient).DownloadFile($regdiffUrl, $regdiffArchivePath)
7z x $regdiffArchivePath
cp $regdiffName/* C:\ProgramData\chocolatey\bin\
rm -r -fo $regdiffArchivePath
rm -r -fo $regdiffName
which regdiff
