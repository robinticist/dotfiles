#!/usr/bin/env bash
#
# Terminal environment bootstrap. Safe to re-run: every step is skipped when
# it is already done, and nothing is deleted or overwritten.
#
#   ./install.sh          install and link
#   ./install.sh --dry-run   show what would happen, change nothing
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

FORMULAE=(git stow tmux neovim fzf eza bat zoxide powerlevel10k)
CASKS=(alacritty font-meslo-lg-nerd-font)

# repo|destination
CLONES=(
  "https://github.com/alacritty/alacritty-theme|$DOTFILES/.config/alacritty/themes"
  "https://github.com/tmux-plugins/tpm|$DOTFILES/.tmux/plugins/tpm"
)

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
skip() { printf '  \033[90m·\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
run()  { if (( DRY_RUN )); then printf '  \033[36m→\033[0m %s\n' "$*"; else "$@"; fi; }

(( DRY_RUN )) && bold "DRY RUN — nothing will be changed"

# ---------------------------------------------------------------- homebrew
bold "Homebrew"
if command -v brew >/dev/null 2>&1; then
  ok "already installed"
else
  warn "not installed. Install it first, then re-run this script:"
  echo '      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

# ---------------------------------------------------------------- packages
bold "Packages"
installed_formulae="$(brew list --formula -1 2>/dev/null || true)"
installed_casks="$(brew list --cask -1 2>/dev/null || true)"

missing_formulae=()
for pkg in "${FORMULAE[@]}"; do
  if grep -qx "$pkg" <<<"$installed_formulae"; then skip "$pkg"; else missing_formulae+=("$pkg"); fi
done
missing_casks=()
for pkg in "${CASKS[@]}"; do
  if grep -qx "$pkg" <<<"$installed_casks"; then skip "$pkg"; else missing_casks+=("$pkg"); fi
done

if (( ${#missing_formulae[@]} )); then
  run brew install "${missing_formulae[@]}" && ok "installed: ${missing_formulae[*]}"
fi
if (( ${#missing_casks[@]} )); then
  run brew install --cask "${missing_casks[@]}" && ok "installed: ${missing_casks[*]}"
fi
(( ${#missing_formulae[@]} + ${#missing_casks[@]} )) || ok "nothing to install"

# ---------------------------------------------------------------- clones
bold "External repos"
for entry in "${CLONES[@]}"; do
  url="${entry%%|*}"
  dest="${entry##*|}"
  name="$(basename "$dest")"
  if [[ -d "$dest/.git" ]]; then
    skip "$name — already cloned"
  elif [[ -d "$dest" && -n "$(ls -A "$dest" 2>/dev/null)" ]]; then
    warn "$name — $dest exists but is not a git clone, leaving it alone"
  else
    run git clone --depth=1 "$url" "$dest" && ok "$name"
  fi
done

# ---------------------------------------------------------------- stow
bold "Symlinks (stow)"
# stow always prints a "simulation mode" notice under -n; anything else is a real conflict.
stow_check="$(stow -n -d "$DOTFILES" -t "$HOME" . 2>&1 | grep -v 'simulation mode' || true)"
if [[ -n "$stow_check" ]]; then
  warn "stow reports conflicts — existing files are in the way:"
  sed 's/^/      /' <<<"$stow_check"
  warn "resolve them by hand, or adopt them into the repo with:"
  echo "      stow --adopt -d $DOTFILES -t $HOME .   # then check 'git diff'"
else
  run stow -d "$DOTFILES" -t "$HOME" . && ok "linked into $HOME"
fi

# ---------------------------------------------------------------- verify
# .zshrc locates Homebrew itself, so this should hold even without ~/.zprofile.
bold "Environment check"
if (( DRY_RUN )); then
  skip "skipped in dry-run"
else
  # `whence -p` searches PATH only. `command -v` would match the shell aliases in .zshrc
  # (e.g. `alias bat=...`) and report a missing binary as present.
  probe="$(zsh -ic 'echo "PREFIX=$HOMEBREW_PREFIX"; for t in brew fzf eza bat zoxide nvim tmux; do whence -p $t >/dev/null || echo "MISSING=$t"; done' 2>/dev/null)"
  prefix="$(sed -n 's/^PREFIX=//p' <<<"$probe")"
  if [[ -n "$prefix" ]]; then ok "HOMEBREW_PREFIX resolved to $prefix"; else warn "HOMEBREW_PREFIX is empty — brew was not found by .zshrc"; fi
  if grep -q '^MISSING=' <<<"$probe"; then
    sed -n 's/^MISSING=/  ! not on PATH in a new shell: /p' <<<"$probe"
  else
    ok "all tools resolve in a new shell"
  fi
fi

# ---------------------------------------------------------------- next steps
bold "Remaining manual steps"
cat <<'STEPS'
  1. Open a new shell — zinit bootstraps itself and pulls the zsh plugins
  2. p10k configure          (optional — the committed .p10k.zsh already works)
  3. nvim                    (LazyVim installs its plugins on first launch)
  4. In tmux: prefix + I     (tpm installs the catppuccin theme)
STEPS
