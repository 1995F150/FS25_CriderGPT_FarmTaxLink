@echo off
:: ==============================================
:: FS25 CriderGPT Build Script
:: Author: Jessie Crider (CriderGPT)
:: Version: 1.0.0
:: Purpose: Creates a ModHub-ready .zip file
:: without the extra '-main' folder.
:: ==============================================

setlocal
set MODNAME=FS25_CriderGPT_FarmTaxLink

echo 🚜 Building %MODNAME%.zip ...
echo ----------------------------------------------

:: Go to the script directory
cd /d "%~dp0"

:: Remove any existing ZIP file
if exist "..\%MODNAME%.zip" (
    del "..\%MODNAME%.zip"
)

:: Create new clean ZIP in parent folder
powershell -Command "Compress-Archive -Path * -DestinationPath ('../%MODNAME%.zip') -Force"

echo ----------------------------------------------
echo ✅ Done! Created %MODNAME%.zip in the parent folder.
echo 📂 Location: %cd%\..
echo ----------------------------------------------
pause
endlocal
