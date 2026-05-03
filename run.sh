#!/bin/bash

PROJECT_DIR=~/mech-project
BOARD="$PROJECT_DIR/agent_board.md"
BRIEF="$PROJECT_DIR/my_project.md"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${PURPLE}======================================${NC}"
echo -e "${PURPLE}   MULTI-AGENT MECH PROJECT SYSTEM   ${NC}"
echo -e "${PURPLE}======================================${NC}"
echo ""

# Check brief exists
if [ ! -f "$BRIEF" ]; then
    echo "ERROR: my_project.md not found!"
    echo "Create it at: ~/mech-project/my_project.md"
    exit 1
fi

# Read project details from MD
PROJECT_NAME=$(grep "## Project Name" "$BRIEF" -A1 | tail -1 | xargs)
REPO_NAME=$(grep "## GitHub Repo Name" "$BRIEF" -A1 | tail -1 | xargs)

echo -e "${CYAN}Project loaded: $PROJECT_NAME${NC}"
echo -e "${CYAN}GitHub repo:    $REPO_NAME${NC}"
echo ""
echo -e "${YELLOW}Starting all 6 agents...${NC}"
echo ""

# Initialize board
cat > "$BOARD" << BOARD
# Agent Board
## Project: $PROJECT_NAME

## Agent Status
- [waiting] Master
- [waiting] Researcher  
- [waiting] Coder
- [waiting] Runner
- [waiting] Reviewer
- [waiting] Docs+Git

## Master Plan
TBD

## Research Findings
TBD

## Code Files
TBD

## Test Results
TBD

## Review Notes
TBD

## Final Status
TBD
BOARD

# Setup git
cd "$PROJECT_DIR"
git init -q 2>/dev/null
gh repo create "$REPO_NAME" --public --source=. --push 2>/dev/null || true

# Write prompts for each agent based on my_project.md
BRIEF_CONTENT=$(cat "$BRIEF")

# Master prompt
cat > "$PROJECT_DIR/agents/prompt_master.txt" << PROMPT
You are the MASTER agent for a mechanical engineering project.

Here is the project brief:
$BRIEF_CONTENT

Read agent_board.md. Now write a specific task for each of these agents into agent_board.md under "Master Plan":
1. RESEARCHER - what to search for
2. CODER - exactly what code to write
3. RUNNER - how to test it
4. REVIEWER - what to check
5. DOCS+GIT - what to document and repo name

Be very specific. Write it now.
PROMPT

# Researcher prompt
cat > "$PROJECT_DIR/agents/prompt_researcher.txt" << PROMPT
You are the RESEARCHER agent.

Project: $PROJECT_NAME

Read agent_board.md Master Plan for your task.
Search the web for:
- Best Python libraries for this project
- Key engineering formulas needed
- Example implementations
- Any standards or references

Write ALL findings into agent_board.md under "Research Findings".
Include: library names, pip install commands, formulas, links.
PROMPT

# Coder prompt
cat > "$PROJECT_DIR/agents/prompt_coder.txt" << PROMPT
You are the CODER agent.

Project: $PROJECT_NAME

Read agent_board.md Research Findings carefully.
Write complete, working Python code for this project.
Save code to: $PROJECT_DIR/main.py

Requirements from brief:
$BRIEF_CONTENT

Rules:
- Code must run without errors
- Add comments explaining each section
- Handle invalid inputs gracefully
- Save outputs as specified in brief

Update agent_board.md "Code Files" section when done.
PROMPT

# Runner prompt
cat > "$PROJECT_DIR/agents/prompt_runner.txt" << PROMPT
You are the RUNNER agent.

Project: $PROJECT_NAME

Steps:
1. Install required libraries: pip3 install numpy scipy matplotlib pandas
2. Run: python3 $PROJECT_DIR/main.py
3. If errors occur, fix them in main.py and run again
4. Keep fixing until it runs successfully
5. Show the output

Write results into agent_board.md under "Test Results".
Include: whether it passed or failed, output values, any fixes made.
PROMPT

# Reviewer prompt
cat > "$PROJECT_DIR/agents/prompt_reviewer.txt" << PROMPT
You are the REVIEWER agent.

Project: $PROJECT_NAME

Read main.py carefully. Check for:
1. Mathematical/physics errors in formulas
2. Code bugs or edge cases missed
3. Missing error handling
4. Output format correctness
5. Code quality and readability

Fix any issues directly in main.py.
Write detailed review into agent_board.md under "Review Notes".
PROMPT

# Docs+Git prompt
cat > "$PROJECT_DIR/agents/prompt_docskit.txt" << PROMPT
You are the DOCS and GIT agent.

Project: $PROJECT_NAME
Repo: $REPO_NAME

Steps:
1. Read main.py and agent_board.md
2. Write README.md with:
   - Project description
   - Installation: pip install -r requirements.txt  
   - Usage with examples
   - Sample output
   - License: MIT
3. Create requirements.txt with all libraries used
4. Run: git add .
5. Run: git commit -m "feat: $PROJECT_NAME - multi-agent build"
6. Run: git push

Update agent_board.md "Final Status" with GitHub link when done.
PROMPT

echo -e "${GREEN}All prompts written!${NC}"
echo ""
echo -e "${BLUE}Launching agents in background...${NC}"
echo ""

# Run all agents in parallel background processes
run_agent() {
    local AGENT=$1
    local PROMPT_FILE="$PROJECT_DIR/agents/prompt_${AGENT}.txt"
    local LOG="$PROJECT_DIR/agents/log_${AGENT}.txt"
    
    echo -e "${CYAN}Starting $AGENT agent...${NC}"
    
    PROMPT=$(cat "$PROMPT_FILE")
    gemini --prompt "$PROMPT" > "$LOG" 2>&1
    
    echo -e "${GREEN}$AGENT DONE! Log: $LOG${NC}"
}

# Master runs first, then rest in parallel
echo -e "${YELLOW}[1/6] Running MASTER...${NC}"
run_agent "master"
echo ""

echo -e "${YELLOW}[2-6] Running remaining 5 agents in parallel...${NC}"
run_agent "researcher" &
run_agent "coder" &
run_agent "runner" &
run_agent "reviewer" &
run_agent "docskit" &

# Wait for all background jobs
wait

echo ""
echo -e "${PURPLE}======================================${NC}"
echo -e "${GREEN}   ALL AGENTS DONE!${NC}"
echo -e "${PURPLE}======================================${NC}"
echo ""
echo -e "${CYAN}Check your project:${NC}"
echo -e "  Files:  ls ~/mech-project/"
echo -e "  Board:  cat ~/mech-project/agent_board.md"
echo -e "  GitHub: https://github.com/$(gh api user --jq .login)/$REPO_NAME"
echo ""
