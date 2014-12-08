cd %~dp0
"C:\Program Files\7-Zip\7z.exe" a "LudumDare31.love" -tzip *.lua hump\*.lua -r data
mkdir LudumDare31-Laerne

copy /b "LOVE\love.exe"+"LudumDare31.love" "LudumDare31-Laerne\LudumDare31-w81.exe"
copy /b "LOVE\*.dll" "LudumDare31-Laerne"

rem cd "LudumDare31-Laerne"
rem    xcopy /S /E /Y "..\data"
rem cd ..

"C:\Program Files\7-Zip\7z.exe" a "LudumDare31-Laerne.zip" -tzip -r "LudumDare31-Laerne"
pause
