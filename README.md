# Dotfiles

**English** · [한국어](README.ko.md)

macOS setup for Alacritty + tmux + zsh (Powerlevel10k). Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Stow symlinks the contents of this repo into `$HOME`, so editing a file here edits the live config:

```
~/.zshrc      -> dotfiles/.zshrc
~/.tmux.conf  -> dotfiles/.tmux.conf
~/.gitconfig  -> dotfiles/.gitconfig
~/.p10k.zsh   -> dotfiles/.p10k.zsh
~/.config     -> dotfiles/.config        # the whole directory is linked
```

## Setting up a new machine

[Homebrew](https://brew.sh/) has to exist first — everything else is handled by the script:

```bash
git clone git@github.com:robinticist/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` installs the packages, clones the three external repos, runs `stow`, and then
checks that everything resolves in a fresh shell. It is safe to re-run: anything already in
place is skipped, and it never deletes or overwrites. Use `./install.sh --dry-run` to see what
it would do without changing anything.

No paths need editing per machine. `.zshrc` finds Homebrew on its own — `/opt/homebrew`,
`/usr/local`, or Linuxbrew — and derives everything else from `$HOMEBREW_PREFIX` and `$HOME`,
so a `~/.zprofile` with `brew shellenv` is not required. Optional toolchains (JDK, Android
SDK, nvm) are added to `PATH` only on machines where they actually exist.

Four things are left to do by hand afterwards, because each needs its own program to run:

1. Open a new shell — zinit bootstraps itself and pulls the zsh plugins
2. `p10k configure` — optional, the committed `.p10k.zsh` already works
3. `nvim` — LazyVim installs its plugins on first launch
4. In tmux: `prefix` + `I` — tpm installs the catppuccin theme

## What gets installed

### Packages

```bash
brew install git stow tmux neovim fzf eza bat zoxide powerlevel10k
brew install --cask alacritty font-meslo-lg-nerd-font
```

| Tool | Used for |
| ---- | -------- |
| `stow` | symlinking this repo into `$HOME` |
| `fzf` | fuzzy finder + the `fzf-tab` completion UI |
| `eza` | `ls` replacement (see the `l` / `lt` aliases) |
| `bat` | `cat` replacement with syntax highlighting |
| `zoxide` | smarter `cd` (aliased to `c`) |

### External repos

Cloned by the script, and **not tracked in this repo** — they are upstream projects with
their own history:

| Destination | Repo |
| ----------- | ---- |
| `.config/alacritty/themes` | `alacritty/alacritty-theme` |
| `.tmux/plugins/tpm` | `tmux-plugins/tpm` |

> `alacritty.toml` imports a theme from `.config/alacritty/themes`, so Alacritty fails to
> start if that clone is missing. Powerlevel10k comes from brew; `.zshrc` falls back to
> `~/powerlevel10k` if you would rather clone it.

### Plugins — nothing to install by hand

Each plugin manager bootstraps itself:

| Plugins | Manager | Installed when |
| ------- | ------- | -------------- |
| `fzf-tab`, `zsh-completions`, `zsh-syntax-highlighting`, `zsh-autosuggestions` | zinit | first shell start, automatic |
| LazyVim's plugin set | lazy.nvim | first `nvim` launch, automatic |
| `catppuccin/tmux` | tpm | `prefix` + `I` |

### Not installed by the script

This repo is for the terminal environment. Language toolchains referenced by `.zshrc` are
left out on purpose — install them only on machines where you need them:

```bash
brew install nvm pnpm               # node
brew install openjdk@17 openjdk@21  # jvm / android
brew install oh-my-posh             # alternative prompt, disabled in .zshrc
```

## Applying config changes

| File | How it applies |
| ---- | -------------- |
| `.config/alacritty.toml` | automatic — Alacritty live-reloads on save |
| `.tmux.conf` | `tmux source-file ~/.tmux.conf` |
| `.zshrc` | `exec zsh`, or open a new shell |

> Closing and reopening Alacritty does **not** reload `.tmux.conf` — the tmux server keeps
> running across terminal restarts, so the config has to be sourced explicitly.

> Sourcing **adds** bindings but never removes them. After deleting a `bind` line, the old
> binding is still live until you `tmux unbind -n <key>` it or restart the server with
> `tmux kill-server`. A binding that "still works after you deleted it" is this, not a typo.

## Usage

### tmux (prefix: `Ctrl` + `o`)

| Keymap | Action |
| ------ | ------ |
| `prefix` + `c` | New window |
| `prefix` + `h` | Split pane below (stacked) |
| `prefix` + `v` | Split pane to the right (side by side) |
| `Ctrl` + `h` / `j` / `k` / `l` | Move between panes (no prefix) |
| `Option` + arrow keys | Move between panes — the same thing with arrows (no prefix) |
| `Cmd` + `Option` + `left` / `right` | Previous / next window (no prefix) |
| `prefix` + `s` / `S` | Synchronize panes on / off |
| `prefix` + `m` / `M` | Mouse mode on / off |
| `prefix` + `j` | Join a pane from another window (prompts for the source) |
| `prefix` + `J` | Break the current pane out into its own window |
| `prefix` + `[` | Enter copy mode (scrolling up with the wheel also enters it) |
| `prefix` + `]` | Paste buffer |

Copy mode is vi-style: `v` starts a selection, `y` copies and exits, `Escape` cancels.
`osc52` is enabled in Alacritty, so a yank inside tmux also reaches the macOS clipboard —
including over SSH.

#### How the arrow-key bindings work

Both arrow bindings need **both** config files to cooperate. On macOS, Alacritty leaves
`option_as_alt` at `None`, so `Option` produces no Alt modifier, and `Cmd` combos send nothing
to the terminal at all — tmux never sees either keypress on its own.
[`.config/alacritty.toml`](.config/alacritty.toml) therefore emits the escape sequence
explicitly, and [`.tmux.conf`](.tmux.conf) binds it:

| Keys | Alacritty sends | tmux binds it as | Action |
| ---- | --------------- | ---------------- | ------ |
| `Option` + arrows | `ESC [1;3A`–`D` (standard Alt+arrow) | `M-Up` … `M-Right` | `select-pane` |
| `Cmd` + `Option` + `left`/`right` | `ESC [1;11D` / `[1;11C` (private) | `user-keys[0]` / `[1]` | `previous-window` / `next-window` |

`Option` + arrows uses the standard Alt encoding, so tmux recognises it natively — no
`user-keys` entry needed. `Cmd` + `Option` has no standard encoding, so it uses modifier `11`,
a value real terminals never emit, which makes it safe as a private signal.

Binding the keys explicitly this way keeps `option_as_alt` off, so `Option` still composes
characters like `å` and `ç` as usual. If you change a sequence, change it in both files.

### Shell aliases

| Alias | Expands to |
| ----- | ---------- |
| `l` | `eza` long listing with git status and icons |
| `lt` | `eza` tree, 2 levels deep |
| `c` | `z` (zoxide jump) |
| `bat` | `bat -n --color=always --line-range :500` |
| `clean_cache` | `sudo ./delete_cache.sh` |
| `git ss` | `git status` |

### Other behavior

- **Auto-renaming tmux windows** — a `chpwd` hook in `.zshrc` renames the current tmux
  window to the directory you just entered (`~` while at home).
- **`aws-login`** — refreshes AWS SSO credentials, writes a CodeArtifact token into
  `.npmrc` / `.yarnrc`, and adds those files to `.gitignore`. Must be run from a project
  root containing `package.json`.
