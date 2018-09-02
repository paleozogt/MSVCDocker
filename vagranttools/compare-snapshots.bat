@echo on

set SNAPSHOT1=%1
set SNAPSHOT2=%2
set OUTPUT=%3

@echo "comparing %SNAPSHOT1% to %SNAPSHOT2% : %OUTPUT%"

mkdir %OUTPUT%

diff --unchanged-group-format=  %SNAPSHOT1%\files-sorted.txt %SNAPSHOT2%\files-sorted.txt > %OUTPUT%\files.txt
zip %OUTPUT%\files.zip -@ < %OUTPUT%\files.txt

regdiff %SNAPSHOT1%\HKLM.reg %SNAPSHOT2%\HKLM.reg /DIFF %OUTPUT%\HKLM.reg
regdiff %SNAPSHOT1%\HKCU.reg %SNAPSHOT2%\HKCU.reg /DIFF %OUTPUT%\HKCU.reg
regdiff %SNAPSHOT1%\HKCR.reg %SNAPSHOT2%\HKCR.reg /DIFF %OUTPUT%\HKCR.reg
regdiff %SNAPSHOT1%\HKU.reg %SNAPSHOT2%\HKU.reg /DIFF %OUTPUT%\HKU.reg
regdiff %SNAPSHOT1%\HKCC.reg %SNAPSHOT2%\HKCC.reg /DIFF %OUTPUT%\HKCC.reg
