@echo off
echo Generating exact Facebook key hash for your system...
echo.

REM Try to get the exact key hash using keytool
keytool -exportcert -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -keypass android 2>nul

echo.
echo If the command above worked, run this to get the hash:
echo keytool -exportcert -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -keypass android | openssl sha1 -binary ^| openssl base64 2>nul

echo.
echo If OpenSSL is not installed, install it from: https://slproweb.com/products/Win32OpenSSL.html
echo.
echo Or use Android Studio: Gradle tab -^> your-app -^> Tasks -^> android -^> signingReport
echo.
pause
