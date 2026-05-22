@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Create WIM from Folder

echo ============================================
echo     Folder to WIM Creator
echo ============================================
echo.

:LOOP

:: Prompt for folder path
set /p "sourceFolder=Enter full folder path to pack into WIM (or type EXIT to quit): "

if /i "%sourceFolder%"=="exit" (
    echo Exiting tool...
    pause
    exit /b 0
)

:: Remove surrounding quotes if user pasted quoted path
set "sourceFolder=%sourceFolder:"=%"

:: Verify folder existence
if not exist "%sourceFolder%\" (
    echo Folder not found:
    echo   "%sourceFolder%"
    echo.
    goto LOOP
)

:: Get folder name and parent path
for %%F in ("%sourceFolder%") do (
    set "folderName=%%~nxF"
    set "parentFolder=%%~dpF"
)

:: Define output WIM path in the same parent folder
set "wimPath=%parentFolder%%folderName%.wim"

echo.
echo --------------------------------------------
echo Creating WIM file from folder:
echo   "%sourceFolder%"
echo.
echo Output WIM file:
echo   "%wimPath%"
echo --------------------------------------------
echo.

:: Create WIM image from folder
dism /capture-image /imagefile:"%wimPath%" /capturedir:"%sourceFolder%" /name:"%folderName%" /compress:max /checkintegrity

if errorlevel 1 (
    echo.
    echo Failed to create WIM file.
    echo Please run this script as Administrator.
    echo.
    goto LOOP
)

echo.
echo WIM file created successfully:
echo   "%wimPath%"
echo.

echo You can now process another folder.
echo --------------------------------------------
echo.

goto LOOP

exit /b 0