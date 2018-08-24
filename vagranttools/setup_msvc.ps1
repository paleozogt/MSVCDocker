param (
    [Parameter(Mandatory=$true)][string]$msvc_ver
 )

If ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
    $programFilesX86= ${env:ProgramFiles(x86)}
} Else {
    $programFilesX86= $env:ProgramFiles
}

If ($msvc_ver -eq "12") {
    # sadly no "build tools" for 2013
    choco install -y visualstudioexpress2013windowsdesktop vs2013.4
} ElseIf ($msvc_ver -eq "14") {
    choco install -y visualcpp-build-tools --version 14.0.25420.1
} ElseIf ($msvc_ver -eq "15") {
    choco install -y visualcpp-build-tools --version 15.0.26228.20170424

    If ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
        $vcvarsbat="$programFilesX86\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
    } Else {
        $vcvarsbat="$programFilesX86\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvars32.bat"
    }

    # There's a bug in this version of the msvc installer where choco will exit before the installer is done.
    # We have to some workarounds to wait until everything is done.

    # wait for the vcvars file to appear
    while (!(Test-Path $vcvarsbat)) {
        echo "waiting for $vcvarsbat"
        Start-Sleep 10
    }

    # wait for the installer process to finish
    echo "waiting for installer to finish"
    Wait-Process -Name vs_installer
}
