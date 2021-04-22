rmdir /s /q %temp%\SamsungBIOS
mkdir %temp%\SamsungBIOS

:start
robocopy %TEMP%\__Samsung_Update %TEMP%\SamsungBIOS /E
:: Uncomment next line for %programfiles(x86)%\UEFI WinFlash
:: robocopy %programfiles(x86)%\UEFI WinFlash %TEMP%\SamsungBIOS /E
goto start