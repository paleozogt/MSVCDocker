@echo on
set CURR_DRIVE=%CD:~0,2%
set CURR_DIR=%CD%
set SNAPSHOT_DIR=%1
@echo snapshotting to %SNAPSHOT_DIR%

%HOMEDRIVE%
cd %HOMEDRIVE%\
mkdir %SNAPSHOT_DIR%

set > %SNAPSHOT_DIR%\env.txt

@echo exporting registry
reg export HKLM %SNAPSHOT_DIR%\HKLM.reg /y
reg export HKCU %SNAPSHOT_DIR%\HKCU.reg /y
reg export HKCR %SNAPSHOT_DIR%\HKCR.reg /y
reg export HKU  %SNAPSHOT_DIR%\HKU.reg /y
reg export HKCC %SNAPSHOT_DIR%\HKCC.reg /y

rm -rf %SNAPSHOT_DIR%\files.txt

@echo listing %SystemRoot%
cd %SystemRoot%
fd -a -t f >> %SNAPSHOT_DIR%\files.txt

@echo listing %ProgramData%
cd %ProgramData%
fd -a -t f >> %SNAPSHOT_DIR%\files.txt

@echo listing %ProgramFiles%
cd %ProgramFiles%
fd -a -t f >> %SNAPSHOT_DIR%\files.txt

@echo listing %ProgramFiles(x86)%
cd %ProgramFiles(x86)%
fd -a -t f >> %SNAPSHOT_DIR%\files.txt

@echo sorting file list
sort %SNAPSHOT_DIR%\files.txt > %SNAPSHOT_DIR%\files-sorted.txt

%CURR_DRIVE%
cd %CURR_DIR%
