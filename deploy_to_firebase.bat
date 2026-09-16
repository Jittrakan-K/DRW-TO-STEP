@echo off
chcp 65001 >nul
echo ===================================================================
echo     AUTOMATION BUILD 3D SOLIDWORKS - FIREBASE DEPLOYER
echo ===================================================================
echo.

set PATH=C:\Users\jittrakan.katprasat\AppData\Local\Programs\node;C:\Program Files\nodejs;%PATH%

echo [1/3] ตรวจสอบการเข้าสู่ระบบ Google Firebase...
call npx --yes firebase-tools login

echo.
echo [2/3] รายชื่อ Firebase Project ของคุณ:
call npx --yes firebase-tools projects:list
echo.

set /p PROJECT_ID="กรุณากรอก Project ID จาก Firebase Console (หรือกด Enter เพื่อใช้โปรเจกต์ปัจจุบัน): "

if not "%PROJECT_ID%"=="" (
    echo กำลังสลับไปใช้โปรเจกต์: %PROJECT_ID%
    call npx --yes firebase-tools use %PROJECT_ID%
)

echo.
echo [3/3] กำลัง Deploy โฟลเดอร์ public ขึ้น Firebase Hosting...
call npx --yes firebase-tools deploy --only hosting

echo.
echo ===================================================================
echo     DEPLOY สำเร็จเรียบร้อยแล้ว!
echo     ระบบ 3D CAD Studio ออนไลน์บน Google Firebase Hosting แล้ว
echo     ไม่ต้องเปิดคอมเครื่องนี้ทิ้งไว้อีกต่อไป เปิดใช้งานได้จากทุกที่!
echo ===================================================================
pause
