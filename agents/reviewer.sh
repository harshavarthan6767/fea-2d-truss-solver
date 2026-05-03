#!/bin/bash
cd ~/mech-project
clear
echo "============================================"
echo "  AGENT 5 - REVIEWER (Checks Quality)"
echo "  Account: Google Account #2"
echo "============================================"
echo ""
echo "PASTE THIS AS YOUR FIRST MESSAGE:"
echo "----------------------------------"
echo "You are the REVIEWER agent. Read all .py files and agent_board.md."
echo "Check for bugs, wrong physics, bad code quality."
echo "Write review notes into agent_board.md under Review Notes."
echo "----------------------------------"
echo ""
gemini
