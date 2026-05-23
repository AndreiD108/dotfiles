# ─── tmux session helpers ─────────────────────────────────────────────────────
# Smart t:  no args -> list (or create default), with name -> attach-or-create
t() {
  if [[ $# -eq 0 ]]; then
    tmux ls 2>/dev/null || tmux new-session
  else
    tmux new-session -A -s "$1"
  fi
}

# Attach or create a session named after the current directory
tp() {
  tmux new-session -A -s "${PWD##*/}"
}

# fzf attach picker (works inside or outside tmux)
ta() {
  local s
  s=$(tmux ls -F '#{session_name}' 2>/dev/null | fzf --height=40% --reverse) || return
  tmux attach -t "$s" 2>/dev/null || tmux switch-client -t "$s"
}

# Kill: arg -> direct, no arg -> fzf picker
tk() {
  if [[ $# -eq 0 ]]; then
    local s
    s=$(tmux ls -F '#{session_name}' 2>/dev/null | fzf --height=40% --reverse) || return
    tmux kill-session -t "$s"
  else
    tmux kill-session -t "$1"
  fi
}

alias tl='tmux ls'
alias tks='tmux kill-server'
