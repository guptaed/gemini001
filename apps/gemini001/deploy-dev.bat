
@echo off
echo ========================================
echo   Deploying to DEVELOPMENT
echo ========================================
echo.
echo Building Flutter web...
call flutter build web --release
echo.
echo Deploying to Firebase Hosting (DEV)...
call firebase deploy --only hosting:gemini001-dev
echo.
echo ========================================
echo   DEV Deployment Complete!
echo   URL: https://gemini001-dev.web.app
echo ========================================
pause
