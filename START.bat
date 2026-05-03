@echo off
echo ======================================
echo    MULTI-AGENT MECH PROJECT SYSTEM
echo ======================================
echo.
echo Opening project editor...
wsl.exe bash -c "nano ~/mech-project/my_project.md"
echo.
echo Launching all 6 agents...
wsl.exe bash -c "cd ~/mech-project && ./run.sh"
pause
