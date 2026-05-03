#!/bin/bash

PROJECT_DIR=~/mech-project
BOARD="$PROJECT_DIR/agent_board.md"
BRIEF="$PROJECT_DIR/my_project.md"
AGENT_NAME=$1
PROMPT_FILE="$PROJECT_DIR/agents/prompt_${AGENT_NAME}.txt"

# Wait for prompt file to exist
echo "[$AGENT_NAME] Starting up..."
while [ ! -f "$PROMPT_FILE" ]; do
    echo "[$AGENT_NAME] Waiting for task..."
    sleep 3
done

# Read the prompt
PROMPT=$(cat "$PROMPT_FILE")
echo "[$AGENT_NAME] Got task! Starting Gemini..."
sleep 2

# Send prompt to gemini automatically
echo "$PROMPT" | gemini --prompt "$PROMPT"

# Mark done
echo "[$AGENT_NAME] DONE" >> "$BOARD"
echo "[$AGENT_NAME] Task complete!"
