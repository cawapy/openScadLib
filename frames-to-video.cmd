@echo off
setlocal

echo.ffmpeg  -framerate 60 -loop 1 -t 10 -i frame%%05d.png output.mp4
echo.
echo.ffmpeg found in:
dir /s/b "%ProgramData%\ffmpeg.exe" "%ProgramFiles%\ffmpeg.exe" "%ProgramFiles(x86)%\ffmpeg.exe" "%ProgramW6432%\ffmpeg.exe" 2>NUL

exit /b 1
