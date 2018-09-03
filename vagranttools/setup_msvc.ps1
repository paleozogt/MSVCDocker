param (
    [Parameter(Mandatory=$true)][string]$msvc_ver,
    [Parameter(Mandatory=$true)][string]$output_dir
 )

If ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
    $programFilesX86= ${env:ProgramFiles(x86)}
} Else {
    $programFilesX86= $env:ProgramFiles
}

If ($msvc_ver -eq "10") {
    # sadly no "build tools" for 2010
    choco install -y vcexpress2010

    $vcvarsbat="$programFilesX86\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"
    $vcvars32="`"$vcvarsbat`" x86"
    $vcvars64="`"$vcvarsbat`" x86_amd64"
} ElseIf ($msvc_ver -eq "11") {
    # sadly no "build tools" for 2012
    choco install -y visualstudio2012wdx

    $vcvarsbat="$programFilesX86\Microsoft Visual Studio 11.0\VC\vcvarsall.bat"
    $vcvars32="`"$vcvarsbat`" x86"
    $vcvars64="`"$vcvarsbat`" x86_amd64"

} ElseIf ($msvc_ver -eq "12") {
    # sadly no "build tools" for 2013
    choco install -y visualstudioexpress2013windowsdesktop vs2013.4

    $vcvarsbat="$programFilesX86\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"
    $vcvars32="`"$vcvarsbat`" x86"
    $vcvars64="`"$vcvarsbat`" x86_amd64"
} ElseIf ($msvc_ver -eq "14") {
    choco install -y visualcpp-build-tools --version 14.0.25420.1

    $vcvarsbat="$programFilesX86\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
    $vcvars32="`"$vcvarsbat`" x86"
    $vcvars64="`"$vcvarsbat`" amd64"
} ElseIf ($msvc_ver -eq "15") {
    choco install -y visualcpp-build-tools --version 15.0.26228.20170424

    $vcvars32="`"$programFilesX86\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvars32.bat`""
    $vcvars64="`"$programFilesX86\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvars64.bat`""

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

choco install -y vswhere

echo "vcvars32 $vcvars32"
echo "vcvars64 $vcvars64"

mkdir -Force "$output_dir"

$vcvars32_export="$output_dir\vcvars32.txt"
echo "exporting $vcvars32_export"
cmd /c "$vcvars32 && set > $vcvars32_export"

$vcvars64_export="$output_dir\vcvars64.txt"
echo "exporting $vcvars64_export"
cmd /c "$vcvars64 && set > $vcvars64_export"

refreshenv
