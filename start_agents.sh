#!/bin/bash
PROJECT_DIR=~/mech-project
mkdir -p $PROJECT_DIR

# Create the shared message board
cat > $PROJECT_DIR/agent_board.md << 'EOF'
## Agent Board
### Tasks
- [ ] Research
- [ ] Code
- [ ] Test
- [ ] Review
- [ ] Docs
- [ ] Git push

### Messages
EOF

# Start tmux with 6 panes
tmux new-session -d -s agents

# Pane 1 - Master
tmux send-keys -t agents:0 "cd $PROJECT_DIR && gemini" Enter

# Pane 2 - Researcher  
tmux split-window -h -t agents:0
tmux send-keys -t agents:0.1 "cd $PROJECT_DIR && gemini" Enter

# Pane 3 - Coder
tmux split-window -v -t agents:0.0
tmux send-keys -t agents:0.2 "cd $PROJECT_DIR && gemini" Enter

# Pane 4 - Runner
tmux split-window -v -t agents:0.1
tmux send-keys -t agents:0.3 "cd $PROJECT_DIR && gemini" Enter

# Window 2 - Reviewer + Docs + Git
tmux new-window -t agents:1
tmux send-keys -t agents:1 "cd $PROJECT_DIR && gemini" Enter
tmux split-window -h -t agents:1
tmux send-keys -t agents:1.1 "cd $PROJECT_DIR && gemini" Enter
tmux split-window -v -t agents:1.0
tmux send-keys -t agents:1.2 "cd $PROJECT_DIR && gemini" Enter

tmux attach -t agents

