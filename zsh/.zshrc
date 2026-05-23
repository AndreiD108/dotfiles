# ─── PATH dedup ───────────────────────────────────────────────────────────────
# Re-sourcing this file otherwise grows PATH unboundedly, since most lines
# below prepend to it without checking. typeset -U makes assignments to path/
# PATH automatically deduplicated.
typeset -U path PATH

# ─── Zinit ────────────────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light MichaelAquilina/zsh-you-should-use
zinit light MichaelAquilina/zsh-autoswitch-virtualenv

# ─── History ──────────────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# ─── Shell Options ────────────────────────────────────────────────────────────
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt GLOB_DOTS

# ─── Completion ───────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ─── Key Bindings ─────────────────────────────────────────────────────────────
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[3~' delete-char
bindkey '^[[5~' history-substring-search-up
bindkey '^[[6~' history-substring-search-down

# Prevent terminal from freezing on Ctrl-S (which is our tmux prefix)
stty -ixon

# ─── PATH ─────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# ─── Editor ───────────────────────────────────────────────────────────────────
export EDITOR=nano

# ─── Aliases ──────────────────────────────────────────────────────────────────
alias sourcezsh='source ~/.zshrc'

# ─── Prompt ───────────────────────────────────────────────────────────────────
command -v starship >/dev/null && eval "$(starship init zsh)"

# ─── Zoxide ──────────────────────────────────────────────────────────────────
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# ─── fzf shell integration (Ctrl-R, Ctrl-T, Alt-C) ───────────────────────────
command -v fzf >/dev/null && eval "$(fzf --zsh)" 2>/dev/null

# ─── Shared config from this dotfiles repo (tmux aliases, etc.) ──────────────
for f in ~/.config/zsh-shared/*.zsh(N); do source "$f"; done

# ─── Machine-specific config (aliases, env vars, toolchains, etc.) ───────────
# NOT in the dotfiles repo. Put per-machine files in ~/.config/zsh/
for f in ~/.config/zsh/*.zsh(N); do source "$f"; done
