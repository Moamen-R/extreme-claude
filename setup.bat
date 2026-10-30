@echo off
title Claude Code & AI Ecosystem Setup
echo ========================================================
echo   Launching Claude Code & AI Ecosystem Installer...
echo ========================================================
powershell -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0Install-ClaudeSetup.ps1"
echo.
pause
