#!/usr/bin/env bash
#
# Querio dev environment setup
# ----------------------------
# Self-contained, give-to-anyone installer. It will:
#   1. Install the tools the session needs (tmux, mise, lazygit) + gum for the UI
#   2. Find your local Querio checkout
#   3. Write a personalized `querio` launcher that opens the full tmux layout
#   4. Optionally install a tmux config (Ctrl+S prefix, mouse, quick window cycling)
#
# Usage:  bash setup.sh
#
set -euo pipefail

# --- tiny styling helpers (used before gum is available) ---------------------
BOLD=$'\033[1m'; DIM=$'\033[2m'; GREEN=$'\033[32m'; YEL=$'\033[33m'; RED=$'\033[31m'; CYAN=$'\033[36m'; RESET=$'\033[0m'
say()  { printf '%s\n' "$*"; }
info() { printf '%s•%s %s\n' "$CYAN" "$RESET" "$*"; }
ok()   { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$YEL" "$RESET" "$*"; }
die()  { printf '%s✗ %s%s\n' "$RED" "$*" "$RESET" >&2; exit 1; }

# --- platform + package manager detection ------------------------------------
OS="$(uname -s)"
PKG=""           # how we install things
install_pkg() { die "no package manager detected"; }   # replaced below

detect_pkg() {
  if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
      warn "Homebrew is not installed — it's the easiest way to get the dependencies."
      read -r -p "Install Homebrew now? [Y/n] " a
      if [[ "${a:-Y}" =~ ^[Yy]?$ ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # make brew available for the rest of this run
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
      else
        die "Homebrew required on macOS. Re-run when ready."
      fi
    fi
    PKG="brew"
    install_pkg() { brew install "$@"; }
  elif command -v apt-get >/dev/null 2>&1; then
    PKG="apt"
    install_pkg() { sudo apt-get update -qq && sudo apt-get install -y "$@"; }
  elif command -v dnf >/dev/null 2>&1; then
    PKG="dnf"; install_pkg() { sudo dnf install -y "$@"; }
  elif command -v pacman >/dev/null 2>&1; then
    PKG="pacman"; install_pkg() { sudo pacman -S --noconfirm "$@"; }
  else
    PKG=""
  fi
}

# --- bootstrap gum (the "nice CLI" that powers this wizard) -------------------
# Everything still works without it; we just fall back to plain read prompts.
HAVE_GUM=0
bootstrap_gum() {
  if command -v gum >/dev/null 2>&1; then HAVE_GUM=1; return; fi
  case "$PKG" in
    brew)   brew install gum >/dev/null 2>&1 && HAVE_GUM=1 ;;
    apt)
      # Charm apt repo
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg 2>/dev/null || true
      echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
      sudo apt-get update -qq && sudo apt-get install -y gum >/dev/null 2>&1 && HAVE_GUM=1 ;;
    pacman) sudo pacman -S --noconfirm gum >/dev/null 2>&1 && HAVE_GUM=1 ;;
    *)      : ;;
  esac
  command -v gum >/dev/null 2>&1 && HAVE_GUM=1 || true
}

# --- prompt wrappers: use gum when present, else plain bash -------------------
ui_confirm() { # $1 = question ; returns 0 for yes
  if [[ "$HAVE_GUM" == 1 ]]; then gum confirm "$1"; else
    read -r -p "$1 [Y/n] " a; [[ "${a:-Y}" =~ ^[Yy]?$ ]]; fi
}
ui_input() {  # $1 = prompt ; $2 = default ; echoes answer
  if [[ "$HAVE_GUM" == 1 ]]; then
    gum input --prompt "$1 " --value "$2" --width 80
  else
    read -r -p "$1 [$2] " a; echo "${a:-$2}"; fi
}
ui_spin() {   # $1 = title ; rest = command
  local title="$1"; shift
  if [[ "$HAVE_GUM" == 1 ]]; then gum spin --title "$title" -- "$@"; else
    info "$title"; "$@"; fi
}
ui_header() {
  if [[ "$HAVE_GUM" == 1 ]]; then
    gum style --border rounded --margin "1 0" --padding "1 3" --border-foreground 212 \
      "$BOLD Querio dev environment $RESET" "Tmux session: app · cee · gateway · lazygit · claude"
  else
    say ""; say "${BOLD}=== Querio dev environment setup ===${RESET}"
    say "${DIM}Tmux session: app · cee · gateway · lazygit · claude${RESET}"; say ""
  fi
}

# === run =====================================================================
detect_pkg
[[ -z "$PKG" ]] && warn "No known package manager — you'll need to install tools manually."
bootstrap_gum
ui_header

# --- 1. dependencies ---------------------------------------------------------
# name | command-to-check | brew pkg | apt pkg | why
check_dep() {
  local name="$1" cmd="$2" pkg="$3" why="$4"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$name already installed"
    return
  fi
  warn "$name not found — $why"
  if [[ -z "$PKG" ]]; then
    warn "  install '$cmd' manually, then re-run."
    return
  fi
  if ui_confirm "Install $name now?"; then
    # Run in the foreground (no spinner) so any sudo password prompt stays visible.
    info "Installing $name…"
    if install_pkg "$pkg"; then ok "$name installed"; else warn "Could not install $name automatically."; fi
  else
    warn "Skipped $name — the session may not fully work without it."
  fi
}

say ""; info "${BOLD}Checking dependencies${RESET}"
check_dep "tmux"    "tmux"    "tmux"    "the terminal multiplexer that runs the layout"
check_dep "mise"    "mise"    "mise"    "runs the dev tasks (mise dev:app, dev:cee, dev:gateway)"
check_dep "lazygit" "lazygit" "lazygit" "the git UI shown in the first pane"

# Claude Code is optional — it powers the second window.
CLAUDE_CMD="claude"
if command -v claude >/dev/null 2>&1; then
  ok "claude (Claude Code) found — second window will run it"
else
  if ui_confirm "Claude Code isn't installed. Use it in the layout anyway (install later)?"; then
    CLAUDE_CMD="claude"
    warn "Install Claude Code later: https://claude.com/claude-code"
  else
    CLAUDE_CMD=""   # leave plain shells in the claude window
    info "Second window will just open plain shells."
  fi
fi

# --- 2. locate the Querio repo ----------------------------------------------
say ""; info "${BOLD}Where is your Querio checkout?${RESET}"
DEFAULT_DIR="$HOME/Developer/Querio/webapp"
[[ -d "$DEFAULT_DIR" ]] || DEFAULT_DIR="$HOME/Querio/webapp"
while true; do
  REPO_DIR="$(ui_input "Path to Querio webapp dir:" "$DEFAULT_DIR")"
  REPO_DIR="${REPO_DIR/#\~/$HOME}"          # expand leading ~
  if [[ -d "$REPO_DIR" ]] && ( [[ -f "$REPO_DIR/mise.toml" ]] || [[ -f "$REPO_DIR/.mise.toml" ]] || [[ -f "$REPO_DIR/.config/mise/config.toml" ]] ); then
    ok "Found Querio at $REPO_DIR"; break
  fi
  warn "That path doesn't look like the Querio webapp (no mise config found)."
  ui_confirm "Use it anyway?" && { REPO_DIR="$REPO_DIR"; break; }
done

# --- 3. write the personalized launcher -------------------------------------
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
LAUNCHER="$BIN_DIR/querio"

# Build the claude window block depending on availability
if [[ -n "$CLAUDE_CMD" ]]; then
  CLAUDE_BLOCK=$(cat <<EOF
tmux send-keys -t \$SESSION:claude.0 "$CLAUDE_CMD" Enter
tmux split-window -h -t \$SESSION:claude -c \$DIR
tmux send-keys -t \$SESSION:claude.1 "$CLAUDE_CMD" Enter
EOF
)
else
  CLAUDE_BLOCK="tmux split-window -h -t \$SESSION:claude -c \$DIR"
fi

cat > "$LAUNCHER" <<EOF
#!/usr/bin/env bash
# Generated by Querio setup.sh — launches the dev tmux session.
SESSION="querio"
DIR="$REPO_DIR"

# Attach if the session already exists
tmux has-session -t \$SESSION 2>/dev/null && exec tmux attach -t \$SESSION

# Window 1: dev  (lazygit | app / cee | gateway)
tmux new-session -d -s \$SESSION -n "dev" -c \$DIR
tmux send-keys -t \$SESSION:dev.0 "lazygit" Enter
tmux split-window -h -t \$SESSION:dev -c \$DIR
tmux send-keys -t \$SESSION:dev.1 "mise dev:app"
tmux split-window -v -t \$SESSION:dev.1 -c \$DIR
tmux split-window -h -t \$SESSION:dev.2 -c \$DIR
tmux send-keys -t \$SESSION:dev.2 "mise dev:cee"
tmux send-keys -t \$SESSION:dev.3 "mise dev:gateway"
tmux resize-pane -t \$SESSION:dev.3 -x 50%

# Window 2: claude
tmux new-window -t \$SESSION -n "claude" -c \$DIR
$CLAUDE_BLOCK

# Focus the lazygit pane on window 1
tmux select-window -t \$SESSION:dev
tmux select-pane -t \$SESSION:dev.0
exec tmux attach -t \$SESSION
EOF
chmod +x "$LAUNCHER"
ok "Launcher written to $LAUNCHER"

# Note about the dev panes: send-keys without Enter leaves the command typed but
# not run, so nothing starts until you press Enter in each pane (matches the
# original setup — lets you eyeball before booting services).

# Make sure ~/.local/bin is on PATH
if ! echo ":$PATH:" | grep -q ":$BIN_DIR:"; then
  SHELL_RC="$HOME/.zshrc"; [[ "${SHELL:-}" == *bash ]] && SHELL_RC="$HOME/.bashrc"
  if ui_confirm "Add $BIN_DIR to your PATH in $SHELL_RC?"; then
    printf '\n# Querio launcher\nexport PATH="%s:$PATH"\n' "$BIN_DIR" >> "$SHELL_RC"
    ok "Added to PATH (restart your shell or 'source $SHELL_RC')"
  else
    warn "Run the launcher directly with: $LAUNCHER"
  fi
fi

# --- 4. optional tmux config -------------------------------------------------
say ""
if ui_confirm "Install the recommended tmux config (Ctrl+S prefix, mouse, Ctrl+A to cycle windows)?"; then
  TCONF="$HOME/.tmux.conf"
  if [[ -f "$TCONF" ]]; then
    cp "$TCONF" "$TCONF.bak.$(date +%s)" && warn "Backed up existing ~/.tmux.conf"
  fi
  cat > "$TCONF" <<'EOF'
# prefix is ctrl+s
unbind C-b
set-option -g prefix C-s
bind-key C-s send-prefix

# ctrl+a cycles windows (no prefix needed)
bind-key -n C-a next-window

# enable mouse (click to focus panes, resize, scroll)
set -g mouse on
EOF
  ok "Wrote ~/.tmux.conf"
fi

# --- done --------------------------------------------------------------------
say ""
if [[ "$HAVE_GUM" == 1 ]]; then
  gum style --foreground 212 "All set! 🎉"
else
  ok "All set!"
fi
say "Start your dev session any time with:  ${BOLD}querio${RESET}"
say "${DIM}(or run $LAUNCHER directly if PATH isn't reloaded yet)${RESET}"
say ""
ui_confirm "Launch the Querio session now?" && exec "$LAUNCHER"
