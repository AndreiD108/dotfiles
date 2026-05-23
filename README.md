# dotfiles

Portable tmux + zsh + starship config, managed with GNU stow.

## Quick install (fresh machine)

```sh
git clone https://github.com/AndreiD108/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The script detects the package manager (`apt`/`brew`/`dnf`/`pacman`/`apk`),
installs everything, then symlinks configs into `$HOME` via stow.

If existing config files would be overwritten, the script aborts and lists them.
Re-run with `--backup` to move them to `<path>.backup.<timestamp>` first.

```sh
./install.sh --backup       # move conflicting files aside before stowing
./install.sh --skip-pkg     # skip system package installs
./install.sh --skip-tools   # skip starship and zoxide installers
```

After install, switch your default shell to zsh:

```sh
chsh -s $(command -v zsh)
```

## Layout

```
.
├── install.sh
├── tmux/
│   └── .tmux.conf
├── zsh/
│   ├── .zshrc
│   └── .config/
│       └── zsh-shared/
│           └── tmux.zsh           # session helpers (t, tp, ta, tk, tks, tl)
├── starship/
│   └── .config/
│       └── starship.toml          # Catppuccin Mocha prompt
└── bin/
    └── .local/
        └── bin/
            └── th                 # tmux cheatsheet
```

Each top-level dir is a stow "package" — its tree mirrors what gets symlinked
into `$HOME`.

## Per-machine config (`machine.zsh`)

`.zshrc` sources two directories at the end:

- `~/.config/zsh-shared/` — files installed by *this repo*
- `~/.config/zsh/`        — your **machine-local** files, not in this repo

Anything host-specific (PATH additions, language toolchains, work env vars,
machine-tuned settings) belongs in a file under `~/.config/zsh/`, e.g.
`~/.config/zsh/machine.zsh`. See `machine.zsh.example` in this repo for the
typical shape.

## Commands

Once installed:

| Command | What it does |
|---|---|
| `t` | List tmux sessions |
| `t <name>` | Attach to `<name>`, create if missing |
| `tp` | Attach/create session named after current dir |
| `tl` | `tmux ls` |
| `ta` | fzf-pick a session to attach to |
| `tk` | fzf-pick a session to kill |
| `tk <name>` | Kill `<name>` directly |
| `tks` | Kill the whole tmux server |
| `th` | Print the tmux cheatsheet (prefix bindings + aliases) |

tmux prefix is `Ctrl-s`. Run `th` any time to see the bindings.

## Notes

- **Ubuntu/Debian binary names:** `fd-find` installs as `fdfind`, `bat` as
  `batcat`. If you want `fd` and `bat` as command names, alias them in your
  `~/.config/zsh/machine.zsh`.
- **First zsh start** auto-clones zinit, then zinit auto-installs the plugins
  listed in `.zshrc`. Initial start is slower; subsequent starts are fast.
- **`stty -ixon`** in the zshrc disables terminal flow control, so `Ctrl-s`
  (our tmux prefix) doesn't freeze the terminal.
