@echo off
title Claude Code and AI Ecosystem Setup
echo ========================================================
echo   Launching Claude Code and AI Ecosystem Installer...
echo ========================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-ClaudeSetup.ps1"
echo.
pause
