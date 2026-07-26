# Language Environment
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Alacritty
# https://github.com/alacritty/alacritty/blob/master/INSTALL.md#zsh
fpath+=${ZDOTDIR:-~}/.zsh_functions

# Oh My Posh (p10k 테마와 중복 실행을 방지하기 위해 주석 처리, 필요 시 주석 해제)
# eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_frappe.omp.json')"

# Zinit
# https://github.com/zdharma-continuum/zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# fzf plugin
zinit light Aloxaf/fzf-tab

# Keybindings
# https://quickref.me/emacs.html
bindkey -e

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Completion styling
# ignore Capitalized character
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=2 --color=always --all --long --git --no-filesize --icons=always --no-time --no-user --no-permissions $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# fzf-catppuccin
# https://github.com/catppuccin/fzf
export FZF_DEFAULT_OPTS=" \
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"

# Shell integrations
# fzf
eval "$(fzf --zsh)"

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi

# powerlevel10k 테마 로드
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Aliases
alias l='eza --color=always --all --long --git --no-filesize --icons=always --no-time --no-user'
alias lt='eza --tree --level=2 --color=always --all --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
alias bat='bat -n --color=always --line-range :500'
alias clean_cache='sudo ./delete_cache.sh'
alias c="z"

eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/dotfiles/.p10k.zsh.
[[ ! -f ~/dotfiles/.p10k.zsh ]] || source ~/dotfiles/.p10k.zsh

# nvm
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# openjdk
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"

# 현재 경로의 프로젝트에서만 적용되도록 변경
aws-login() {
  # 1. 환경 변수 및 상수 설정
  local profile="${1:-DEV-FEDeveloperAccess-047719655696}"
  local domain="codeartifact"
  local owner="047719655696"
  local region="ap-northeast-1"
  local repo_url="codeartifact-${owner}.d.${domain}.${region}.amazonaws.com/npm/npm-store/"

  # 2. 프로젝트 루트 체크
  if [[ ! -f "package.json" ]]; then
    echo "❌ package.json이 없습니다. 프로젝트 루트에서 실행해 주세요."
    return 1
  fi

  # 3. AWS SSO 로그인
  echo "🔐 AWS SSO 로그인 중 ($profile)..."
  if ! aws sso login --profile "$profile"; then
    echo "❌ SSO 로그인 실패"
    return 1
  fi

  # 4. CodeArtifact 토큰 갱신
  echo "🔑 토큰 갱신 중..."
  local token
  token=$(aws codeartifact get-authorization-token --domain "$domain" --domain-owner "$owner" --region "$region" --profile "$profile" --query authorizationToken --output text) || return 1

  # 5. .gitignore 보안 처리 함수
  _update_gitignore() {
    local file=$1
    [ ! -f ".gitignore" ] && touch ".gitignore"
    if ! grep -q "^${file}$" .gitignore; then
      echo -e "\n# AWS CodeArtifact\n$file" >> .gitignore
      echo "🛡️  $file -> .gitignore 추가 완료"
    fi
  }

  # 6. 설정 파일 생성 (.npmrc 공통)
  echo "registry=https://registry.npmjs.org/" > .npmrc
  echo "@aj-fe:registry=https://${repo_url}" >> .npmrc
  echo "//${repo_url}:_authToken=${token}" >> .npmrc
  _update_gitignore ".npmrc"

  # 7. 패키지 매니저별 맞춤 설정
  if [[ -f "yarn.lock" ]]; then
    echo "📦 Yarn 감지: .yarnrc 설정 중..."
    echo "\"@aj-fe:registry\" \"https://${repo_url}\"" > .yarnrc
    _update_gitignore ".yarnrc"
  elif [[ -f "pnpm-lock.yaml" ]]; then
    echo "📦 pnpm 감지: .npmrc 설정을 공유합니다."
  elif [[ -f "package-lock.json" ]]; then
    echo "📦 npm 감지 완료."
  fi

  echo "✅ 모든 설정이 완료되었습니다!"
}

# ----------------------------------------------------
#  플러그인 & 완성 기능 로드 (한글 간섭 최적화 및 compinit 정렬)
# ----------------------------------------------------

# 1. 컴플리션 확장 플러그인 로드
zinit light zsh-users/zsh-completions

# 2. Zsh 기본 완성 시스템 초기화 (zsh-completions 인식용)
autoload -Uz compinit
compinit

# 3. 사용자 입력 반응 플러그인 (한글 씹힘 최소화를 위해 최하단 배치)
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity IDE
export PATH="/Users/robinticist/.antigravity-ide/antigravity-ide/bin:$PATH"

# 디렉토리 변경 시 tmux 탭 이름을 현재 폴더명으로 변경
function rename_tmux_window() {
    if [ -n "$TMUX" ]; then
        # 현재 경로의 마지막 폴더 이름만 추출
        local current_dir="${PWD##*/}"
        
        # 홈 디렉토리면 ~ 로 표시
        if [ "$PWD" = "$HOME" ]; then
            current_dir="~"
        fi
        
        # tmux 윈도우 이름 바꾸기 명령어 실행
        tmux rename-window "$current_dir"
    fi
}

# zsh 디렉토리 변경(chpwd) 훅에 함수 등록
autoload -Uz add-zsh-hook
add-zsh-hook chpwd rename_tmux_window

# 처음 tmux 창을 열었을 때 초기 디렉토리 이름을 반영하기 위해 한 번 실행
rename_tmux_window

