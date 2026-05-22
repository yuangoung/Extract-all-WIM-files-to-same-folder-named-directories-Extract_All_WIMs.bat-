@echo off
title Extract WIM (default index=1) to upper Mount folder
echo ============================================
echo     WIM Extractor
echo ============================================
echo.

:LOOP

:: Prompt for .wim path
set /p wimPath=Enter full path to .wim file (or type EXIT to quit): 

if /i "%wimPath%"=="exit" (
    echo Exiting tool...
    pause
    exit /b 0
)

:: Verify existence
if not exist "%wimPath%" (
    echo File not found: "%wimPath%"
    echo.
    goto LOOP
)

:: Extract filename and folder
for %%F in ("%wimPath%") do (
    set "fileName=%%~nF"
    set "fileFolder=%%~dpF"
)

:: Compute upper two levels of the folder path
for %%A in ("%fileFolder%\..") do set "upper1=%%~fA"
for %%B in ("%upper1%\..") do set "upper2=%%~fB"

:: Define final Mount path
set "mountDir=%upper2%\Mount"

:: Create Mount folder if not exists
if not exist "%mountDir%" (
    mkdir "%mountDir%"
)

echo.
echo --------------------------------------------
echo   √
echo --------------------------------------------
echo.

echo Applying image index 1 to folder:
echo   "%mountDir%"
echo.

:: Apply the selected image into Mount folder
dism /apply-image /imagefile:"%wimPath%" /index:1 /applydir:"%mountDir%"
if errorlevel 1 (
    echo Extraction failed. Please run as Administrator.
    echo.
    goto LOOP
)

echo.
echo Extraction completed successfully.
echo.

echo Cleaning up potential mounted images...
dism /cleanup-wim >nul

echo.
set /p delChoice=Do you want to delete the original .wim file? (Y/N): 

if /i "%delChoice%"=="Y" (
    echo Deleting "%wimPath%" ...
    del /f /q "%wimPath%"
    if errorlevel 1 (
        echo Failed to delete. Check permissions.
    ) else (
        echo File deleted successfully.
    )
) else (
    echo Original .wim file kept.
)

echo.
echo Done! Extracted image saved at:
echo   %mountDir%
echo.

echo You can now process the next WIM.
echo --------------------------------------------
echo.

goto LOOP

exit /b 0