#!/usr/bin/env bash
#
# Install dotfiles: packages, user-local tools, and stow-managed symlinks.
#
# Default behavior is SAFE: if any existing config file would be clobbered by
# stow, the script aborts with a list of conflicts. Re-run with --backup to
# move conflicting files to <path>.backup.<timestamp> before stowing.

set -euo pipefail

cd "$(dirname "$0")"
REPO_DIR="$(pwd)"
PACKAGES="tmux zsh starship bin"

BACKUP=0
SKIP_PKG=0
SKIP_TOOLS=0

for arg in "$@"; do
  case "$arg" in
    --backup)     BACKUP=1 ;;
    --skip-pkg)   SKIP_PKG=1 ;;
    --skip-tools) SKIP_TOOLS=1 ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--backup] [--skip-pkg] [--skip-tools]

  --backup       Move conflicting files to <path>.backup.<timestamp> before stowing.
                 Without this flag, the script aborts on conflicts.
  --skip-pkg     Skip system package installs.
  --skip-tools   Skip starship and zoxide user-local installers.
EOF
      exit 0 ;;
    *) echo "Unknown arg: $arg" >&2; exit 1 ;;
  esac
done

# ─── Detect package manager ───────────────────────────────────────────────────
if   command -v apt-get >/dev/null 2>&1; then PM=apt
elif command -v brew    >/dev/null 2>&1; then PM=brew
elif command -v dnf     >/dev/null 2>&1; then PM=dnf
elif command -v pacman  >/dev/null 2>&1; then PM=pacman
elif command -v apk     >/dev/null 2>&1; then PM=apk
else
  echo "No supported package manager found (apt/brew/dnf/pacman/apk)" >&2
  exit 1
fi
echo "Package manager: $PM"

# ─── Install system packages ──────────────────────────────────────────────────
PKGS_COMMON="stow tmux zsh fzf ripgrep jq tree htop ncdu yq git-delta"
PKGS_APT="$PKGS_COMMON fd-find bat"
PKGS_BREW="$PKGS_COMMON fd bat"
PKGS_DNF="$PKGS_COMMON fd-find bat"
PKGS_PACMAN="$PKGS_COMMON fd bat"
PKGS_APK="$PKGS_COMMON fd bat"

if [[ $SKIP_PKG -eq 0 ]]; then
  echo
  echo "Installing system packages..."
  case $PM in
    apt)
      sudo apt-get update
      sudo apt-get install -y $PKGS_APT
      ;;
    brew)   brew install $PKGS_BREW ;;
    dnf)    sudo dnf install -y $PKGS_DNF ;;
    pacman) sudo pacman -S --needed --noconfirm $PKGS_PACMAN ;;
    apk)    sudo apk add $PKGS_APK ;;
  esac
else
  echo "Skipping system packages (--skip-pkg)."
fi

# ─── Install starship + zoxide (binaries only, no config touched) ─────────────
if [[ $SKIP_TOOLS -eq 0 ]]; then
  echo
  mkdir -p "$HOME/.local/bin"
  if ! command -v starship >/dev/null 2>&1; then
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -b "$HOME/.local/bin" -y
  else
    echo "starship already installed."
  fi
  if ! command -v zoxide >/dev/null 2>&1; then
    echo "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  else
    echo "zoxide already installed."
  fi
else
  echo "Skipping starship/zoxide (--skip-tools)."
fi

# ─── Make th executable (in case the +x bit didn't survive git) ───────────────
chmod +x "$REPO_DIR/bin/.local/bin/th"

# ─── Detect conflicts before stowing ──────────────────────────────────────────
echo
echo "Checking for conflicts..."
CONFLICTS=()
while IFS= read -r line; do
  CONFLICTS+=("$line")
done < <(
  for pkg in $PACKAGES; do
    (cd "$REPO_DIR/$pkg" && find . -mindepth 1 \( -type f -o -type l \) -printf '%P\n')
  done | while read -r rel; do
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]]; then
      echo "$target"
    fi
  done
)

if [[ ${#CONFLICTS[@]} -gt 0 ]]; then
  echo
  echo "Conflicts (these files exist and are NOT symlinks):"
  printf '  %s\n' "${CONFLICTS[@]}"
  echo
  if [[ $BACKUP -eq 0 ]]; then
    echo "Aborting. Options:"
    echo "  1. Move the listed files aside manually, then re-run."
    echo "  2. Re-run with --backup to move them to <path>.backup.<timestamp>."
    exit 1
  fi
  TS=$(date +%s)
  echo "Backing up..."
  for f in "${CONFLICTS[@]}"; do
    mv "$f" "$f.backup.$TS"
    echo "  $f  ->  $f.backup.$TS"
  done
fi

# ─── Stow ─────────────────────────────────────────────────────────────────────
echo
echo "Stowing: $PACKAGES"
stow -v -t "$HOME" $PACKAGES

# ─── Done ─────────────────────────────────────────────────────────────────────
echo
echo "Done."
if [[ "${SHELL:-}" != "$(command -v zsh 2>/dev/null)" ]]; then
  echo "To make zsh your default shell:"
  echo "  chsh -s \$(command -v zsh)"
fi
