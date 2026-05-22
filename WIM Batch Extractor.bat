@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Extract all WIM files to same-folder named directories

echo ============================================
echo     WIM Batch Extractor
echo     Extract all .wim files in a folder
echo ============================================
echo.

:LOOP

:: Prompt for folder path
set /p "inputFolder=Enter full folder path containing .wim files (or type EXIT to quit): "

if /i "%inputFolder%"=="exit" (
    echo Exiting tool...
    pause
    exit /b 0
)

:: Remove surrounding quotes if user pasted quoted path
set "inputFolder=%inputFolder:"=%"

:: Verify folder existence
if not exist "%inputFolder%\" (
    echo Folder not found: "%inputFolder%"
    echo.
    goto LOOP
)

:: Check if there are any .wim files
set "foundWim=0"
for %%F in ("%inputFolder%\*.wim") do (
    if exist "%%~fF" set "foundWim=1"
)

if "%foundWim%"=="0" (
    echo No .wim files found in:
    echo   "%inputFolder%"
    echo.
    goto LOOP
)

echo.
echo --------------------------------------------
echo WIM files found. Starting extraction...
echo Source folder:
echo   "%inputFolder%"
echo --------------------------------------------
echo.

:: Ask whether to delete original WIM files after successful extraction
set /p "delChoice=Delete each original .wim file after successful extraction? (Y/N): "

echo.

:: Process every .wim file in the selected folder
for %%F in ("%inputFolder%\*.wim") do (
    if exist "%%~fF" (
        set "wimPath=%%~fF"
        set "fileName=%%~nF"
        set "fileFolder=%%~dpF"
        set "mountDir=%%~dpF%%~nF"

        echo ============================================
        echo Processing WIM:
        echo   "!wimPath!"
        echo.
        echo Applying image index 1 to folder:
        echo   "!mountDir!"
        echo ============================================
        echo.

        :: Create output folder with the same name as the WIM file
        if not exist "!mountDir!\" (
            mkdir "!mountDir!"
            if errorlevel 1 (
                echo Failed to create folder:
                echo   "!mountDir!"
                echo Skipping this WIM.
                echo.
                goto CONTINUE_NEXT
            )
        )

        :: Apply image index 1 into the same-folder named directory
        dism /apply-image /imagefile:"!wimPath!" /index:1 /applydir:"!mountDir!"

        if errorlevel 1 (
            echo.
            echo Extraction failed for:
            echo   "!wimPath!"
            echo Please run this script as Administrator.
            echo Skipping this WIM.
            echo.
            goto CONTINUE_NEXT
        )

        echo.
        echo Extraction completed successfully:
        echo   "!mountDir!"
        echo.

        echo Cleaning up potential mounted images...
        dism /cleanup-wim >nul

        if /i "!delChoice!"=="Y" (
            echo Deleting original WIM:
            echo   "!wimPath!"
            del /f /q "!wimPath!"
            if errorlevel 1 (
                echo Failed to delete. Check permissions.
            ) else (
                echo File deleted successfully.
            )
            echo.
        ) else (
            echo Original WIM file kept.
            echo.
        )

        :CONTINUE_NEXT
        echo --------------------------------------------
        echo.
    )
)

echo All available WIM files have been processed.
echo.

echo You can now process another folder.
echo --------------------------------------------
echo.

goto LOOP

exit /b 0