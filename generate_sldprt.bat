@echo off
chcp 65001 >nul
title SOLIDWORKS 2018 Native Part (.sldprt) Generator
echo ===================================================================
echo      SOLIDWORKS 2018 Native Part (.sldprt) Generator
echo      BA Type Inner Diameter Shaft Automation
echo ===================================================================
echo.

cd /d "%~dp0"
echo กำลังเรียกใช้งาน SOLIDWORKS 2018 เพื่อสร้างไฟล์ .sldprt ของแท้...
echo.
cscript //nologo generate_sldprt.vbs %*

echo.
echo ===================================================================
echo ดำเนินการเสร็จสิ้น! สามารถเปิดไฟล์ .sldprt ใน SolidWorks 2018 ได้ทันที
echo ===================================================================
pause
