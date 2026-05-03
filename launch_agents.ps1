# Run this file in Windows PowerShell (not WSL)
# It opens 6 separate Windows Terminal tabs, one per agent

$wsl = "wsl.exe"

wt.exe `
  new-tab --title "MASTER" -- $wsl -e bash -c "~/mech-project/agents/master.sh; bash" `; `
  new-tab --title "RESEARCHER" -- $wsl -e bash -c "~/mech-project/agents/researcher.sh; bash" `; `
  new-tab --title "CODER" -- $wsl -e bash -c "~/mech-project/agents/coder.sh; bash" `; `
  new-tab --title "RUNNER" -- $wsl -e bash -c "~/mech-project/agents/runner.sh; bash" `; `
  new-tab --title "REVIEWER" -- $wsl -e bash -c "~/mech-project/agents/reviewer.sh; bash" `; `
  new-tab --title "DOCS+GIT" -- $wsl -e bash -c "~/mech-project/agents/docs_git.sh; bash"
