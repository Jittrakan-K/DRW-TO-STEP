@echo off
chcp 65001 >nul
title SOLIDWORKS 3D CAD Studio
echo ===================================================================
echo   SOLIDWORKS 2D Drawing to 3D STEP AP203 & SLDPRT Studio
echo ===================================================================
echo.
cd /d "%~dp0"

set NODE_EXE="C:\Users\jittrakan.katprasat\AppData\Local\Programs\node\node.exe"

if exist %NODE_EXE% (
    echo กำลังเริ่มทำงาน Local CAD Web Server ด้วย Node.js...
    start "" http://127.0.0.1:5000
    %NODE_EXE% server.js
) else (
    echo กำลังเปิดหน้าต่าง SolidWorks Studio บนเบราว์เซอร์...
    start "" http://127.0.0.1:5000
    python server.py
)

pause
