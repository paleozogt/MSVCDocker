@echo on
set CURR_DIR=%CD%
set SNAPSHOT_DIR=%1

cd %HOMEDRIVE%\

mkdir %SNAPSHOT_DIR%
reg export HKLM %SNAPSHOT_DIR%\HKLM.reg /y
reg export HKCU %SNAPSHOT_DIR%\HKCU.reg /y
reg export HKCR %SNAPSHOT_DIR%\HKCR.reg /y
reg export HKU  %SNAPSHOT_DIR%\HKU.reg /y
reg export HKCC %SNAPSHOT_DIR%\HKCC.reg /y

rm -rf %SNAPSHOT_DIR%\files.txt

cd %SystemRoot%
fd -a -t f >> %SNAPSHOT_DIR%\files.txt

cd %ProgramData%
fd -a -t f >> %SNAPSHOT_DIR%\files.txt

cd %ProgramFiles%
fd -a -t f >> %SNAPSHOT_DIR%\files.txt

cd %ProgramFiles(x86)%
fd -a -t f >> %SNAPSHOT_DIR%\files.txt

sort %SNAPSHOT_DIR%\files.txt > %SNAPSHOT_DIR%\files-sorted.txt

cd %CURR_DIR%
