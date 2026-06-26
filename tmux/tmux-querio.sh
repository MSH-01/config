#!/usr/bin/env bash
SESSION="querio"
DIR="$HOME/Developer/Querio/webapp"

# Attach if session already exists
tmux has-session -t $SESSION 2>/dev/null && tmux attach -t $SESSION && exit

# Window 1: dev
tmux new-session -d -s $SESSION -n "dev" -c $DIR

# Left: lazygit
tmux send-keys -t $SESSION:dev.0 "lazygit" Enter

# Split right
tmux split-window -h -t $SESSION:dev -c $DIR

# Top right: main app
tmux send-keys -t $SESSION:dev.1 "mise dev:app"

# Split bottom right
tmux split-window -v -t $SESSION:dev.1 -c $DIR

# Split bottom into two (backend | gateway)
tmux split-window -h -t $SESSION:dev.2 -c $DIR

tmux send-keys -t $SESSION:dev.2 "mise dev:cee"
tmux send-keys -t $SESSION:dev.3 "mise dev:gateway"

# Equalize the two bottom-right panes
tmux resize-pane -t $SESSION:dev.3 -x 50%

# Window 2: claude
tmux new-window -t $SESSION -n "claude" -c $DIR
tmux send-keys -t $SESSION:claude.0 "cc" Enter
tmux split-window -h -t $SESSION:claude -c $DIR
tmux send-keys -t $SESSION:claude.1 "cc" Enter

# Focus window 1, lazygit pane
tmux select-window -t $SESSION:dev
tmux select-pane -t $SESSION:dev.0

tmux attach -t $SESSION
