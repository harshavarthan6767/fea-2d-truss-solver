@echo off
echo Launching 6 Agent Terminals...

start "MASTER" wt.exe -w 0 new-tab --title "MASTER" -- wsl.exe bash -c "cd ~/mech-project && ./agents/master.sh; exec bash"
timeout /t 2 /nobreak >nul

start "RESEARCHER" wt.exe -w 0 new-tab --title "RESEARCHER" -- wsl.exe bash -c "cd ~/mech-project && ./agents/researcher.sh; exec bash"
timeout /t 2 /nobreak >nul

start "CODER" wt.exe -w 0 new-tab --title "CODER" -- wsl.exe bash -c "cd ~/mech-project && ./agents/coder.sh; exec bash"
timeout /t 2 /nobreak >nul

start "RUNNER" wt.exe -w 0 new-tab --title "RUNNER" -- wsl.exe bash -c "cd ~/mech-project && ./agents/runner.sh; exec bash"
timeout /t 2 /nobreak >nul

start "REVIEWER" wt.exe -w 0 new-tab --title "REVIEWER" -- wsl.exe bash -c "cd ~/mech-project && ./agents/reviewer.sh; exec bash"
timeout /t 2 /nobreak >nul

start "DOCS+GIT" wt.exe -w 0 new-tab --title "DOCS+GIT" -- wsl.exe bash -c "cd ~/mech-project && ./agents/docs_git.sh; exec bash"
timeout /t 2 /nobreak >nul

echo All 6 agents launched!
