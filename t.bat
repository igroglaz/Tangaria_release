@echo off

cd /d "C:\games\Tangaria"

start "" "C:\Github\Tangaria_release\tangaria-addon-sdl2.ahk"

start "" /wait "C:\games\Tangaria\mangclient_sdl2.exe"

taskkill /IM AutoHotkey.exe /F