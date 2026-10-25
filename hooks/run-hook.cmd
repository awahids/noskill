@echo off
setlocal enabledelayedexpansion

set "ROOT=%CLAUDE_PLUGIN_ROOT%"
if "%ROOT%"=="" set "ROOT=%~dp0.."

set "RULES=%ROOT%\hooks\core-rules.md"
set "EXTRA=%ROOT%\hooks\startup-extra.md"

echo.
echo ====================================================
echo [ noskill session-start ]
echo ====================================================

if exist "%RULES%" (
  echo [core rules]
  type "%RULES%"
  echo.
)

if exist "%EXTRA%" (
  echo [startup extra]
  type "%EXTRA%"
  echo.
)

echo [startup complete]
echo ====================================================
