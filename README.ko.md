# Dotfiles

[English](README.md) · **한국어**

Alacritty + tmux + zsh (Powerlevel10k) 기반 macOS 설정입니다. [GNU Stow](https://www.gnu.org/software/stow/)로 관리합니다.

## 구조

stow가 이 저장소의 내용을 `$HOME`으로 심볼릭 링크합니다. 따라서 저장소 안의 파일을 수정하면 실제 동작 중인 설정이 바로 바뀝니다.

```
~/.zshrc      -> dotfiles/.zshrc
~/.tmux.conf  -> dotfiles/.tmux.conf
~/.gitconfig  -> dotfiles/.gitconfig
~/.p10k.zsh   -> dotfiles/.p10k.zsh
~/.config     -> dotfiles/.config        # 디렉토리 전체가 링크됨
```

## 새 기기 셋업

[Homebrew](https://brew.sh/)만 먼저 있으면 되고, 나머지는 스크립트가 처리합니다:

```bash
git clone git@github.com:robinticist/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh`는 패키지 설치, 외부 저장소 3개 clone, `stow` 링크를 수행한 뒤, 새 셸에서 모든 도구가
실제로 잡히는지 검증합니다. 여러 번 실행해도 안전합니다 — 이미 되어 있는 것은 건너뛰고, 무엇도
삭제하거나 덮어쓰지 않습니다. `./install.sh --dry-run` 으로 아무것도 바꾸지 않고 수행할 작업만
확인할 수 있습니다.

**기기마다 경로를 수정할 필요가 없습니다.** `.zshrc`가 Homebrew를 스스로 찾고
(`/opt/homebrew`, `/usr/local`, Linuxbrew), 나머지 경로는 `$HOMEBREW_PREFIX` 와 `$HOME` 에서
파생시킵니다. 따라서 `brew shellenv` 가 든 `~/.zprofile` 이 없어도 동작합니다. 선택적 툴체인(JDK,
Android SDK, nvm)은 해당 기기에 실제로 존재할 때만 `PATH` 에 추가됩니다.

이후 손으로 해야 할 것이 네 가지 있습니다. 각각 해당 프로그램을 직접 실행해야 하기 때문입니다:

1. 새 셸 열기 — zinit이 자기 자신을 설치하고 zsh 플러그인을 가져옵니다
2. `p10k configure` — 선택. 커밋된 `.p10k.zsh`를 그대로 써도 됩니다
3. `nvim` — LazyVim이 첫 실행 시 플러그인을 설치합니다
4. tmux 안에서 `prefix` + `I` — tpm이 catppuccin 테마를 설치합니다

## 무엇이 설치되는가

### 패키지

```bash
brew install git stow tmux neovim fzf eza bat zoxide powerlevel10k
brew install --cask alacritty font-meslo-lg-nerd-font
```

| 도구 | 용도 |
| ---- | ---- |
| `stow` | 이 저장소를 `$HOME`으로 심볼릭 링크 |
| `fzf` | 퍼지 파인더 + `fzf-tab` 자동완성 UI |
| `eza` | `ls` 대체 (`l` / `lt` 알리아스 참고) |
| `bat` | 문법 강조가 되는 `cat` 대체 |
| `zoxide` | 더 똑똑한 `cd` (`c`로 알리아스) |

### 외부 저장소

스크립트가 clone하며, **이 저장소에서 추적하지 않습니다.** 각자 별도 히스토리를 가진 upstream
프로젝트이기 때문입니다:

| 설치 위치 | 저장소 |
| --------- | ------ |
| `.config/alacritty/themes` | `alacritty/alacritty-theme` |
| `.tmux/plugins/tpm` | `tmux-plugins/tpm` |

> `alacritty.toml`이 `.config/alacritty/themes`에서 테마를 import하므로, 이 clone이 없으면
> Alacritty가 실행되지 않습니다. Powerlevel10k는 brew로 설치되며, clone을 선호한다면
> `.zshrc`가 `~/powerlevel10k`로 넘어갑니다.

### 플러그인 — 직접 설치할 것 없음

플러그인 관리자들이 각자 자기 자신을 부트스트랩합니다:

| 플러그인 | 관리자 | 설치 시점 |
| -------- | ------ | -------- |
| `fzf-tab`, `zsh-completions`, `zsh-syntax-highlighting`, `zsh-autosuggestions` | zinit | 첫 셸 실행 시 자동 |
| LazyVim 플러그인 일체 | lazy.nvim | 첫 `nvim` 실행 시 자동 |
| `catppuccin/tmux` | tpm | `prefix` + `I` |

### 스크립트가 설치하지 않는 것

이 저장소는 터미널 환경 전용입니다. `.zshrc`가 참조하는 언어 툴체인은 의도적으로 제외했습니다 —
필요한 기기에서만 설치하세요:

```bash
brew install nvm pnpm               # node
brew install openjdk@17 openjdk@21  # jvm / android
brew install oh-my-posh             # 대체 프롬프트, .zshrc에서 비활성화됨
```

## 설정 변경 반영 방법

| 파일 | 반영 방법 |
| ---- | -------- |
| `.config/alacritty.toml` | 자동 — Alacritty가 저장 시 live reload |
| `.tmux.conf` | `tmux source-file ~/.tmux.conf` |
| `.zshrc` | `exec zsh` 또는 새 셸 열기 |

> Alacritty를 껐다 켜도 `.tmux.conf`는 **다시 읽히지 않습니다.** tmux 서버는 터미널 종료와
> 무관하게 계속 살아있기 때문에, 반드시 명시적으로 source해야 합니다.

> source는 바인딩을 **추가**하기만 하고 제거하지 않습니다. `bind` 줄을 지워도 기존 바인딩은
> `tmux unbind -n <키>` 로 직접 없애거나 `tmux kill-server` 로 서버를 재시작할 때까지 계속
> 살아 있습니다. "지웠는데 여전히 동작하는" 바인딩은 오타가 아니라 이 현상입니다.

## 사용법

### tmux (prefix: `Ctrl` + `o`)

| 키맵 | 동작 |
| ---- | ---- |
| `prefix` + `c` | 새 윈도우 생성 |
| `prefix` + `h` | 아래로 페인 분할 (위아래 배치) |
| `prefix` + `v` | 오른쪽으로 페인 분할 (좌우 배치) |
| `Ctrl` + `h` / `j` / `k` / `l` | 페인 간 이동 (prefix 불필요) |
| `Option` + 방향키 | 페인 간 이동 — 위와 같은 동작을 방향키로 (prefix 불필요) |
| `Cmd` + `Option` + `←` / `→` | 이전 / 다음 윈도우 (prefix 불필요) |
| `prefix` + `s` / `S` | 페인 동시 입력 on / off |
| `prefix` + `m` / `M` | 마우스 모드 on / off |
| `prefix` + `j` | 다른 윈도우의 페인 가져오기 (대상을 입력받음) |
| `prefix` + `J` | 현재 페인을 별도 윈도우로 분리 |
| `prefix` + `[` | 복사 모드 진입 (휠 스크롤 업으로도 진입) |
| `prefix` + `]` | 버퍼 붙여넣기 |

복사 모드는 vi 스타일입니다. `v`로 선택 시작, `y`로 복사 후 종료, `Escape`로 취소.
Alacritty에 `osc52`가 켜져 있어서 tmux 안에서 yank한 내용은 SSH 환경에서도 macOS 클립보드로 전달됩니다.

#### 방향키 바인딩이 동작하는 원리

두 방향키 바인딩 모두 **두 설정 파일이 함께** 동작해야 합니다. macOS에서 Alacritty는
`option_as_alt`가 `None`이라 `Option`이 Alt 수정자를 만들지 않고, `Cmd` 조합은 터미널에 아무것도
보내지 않습니다. 즉 tmux는 두 입력 모두 스스로는 받지 못합니다. 그래서
[`.config/alacritty.toml`](.config/alacritty.toml)이 시퀀스를 명시적으로 보내고,
[`.tmux.conf`](.tmux.conf)가 그것을 바인딩합니다.

| 키 | Alacritty가 보내는 것 | tmux가 인식하는 이름 | 동작 |
| -- | -------------------- | ------------------ | ---- |
| `Option` + 방향키 | `ESC [1;3A`~`D` (표준 Alt+화살표) | `M-Up` … `M-Right` | `select-pane` |
| `Cmd` + `Option` + `←`/`→` | `ESC [1;11D` / `[1;11C` (사설) | `user-keys[0]` / `[1]` | `previous-window` / `next-window` |

`Option` + 방향키는 표준 Alt 인코딩이라 tmux가 그대로 인식합니다 — `user-keys` 등록이 필요 없습니다.
`Cmd` + `Option`은 표준 인코딩이 없어서 수정자 값 `11`을 씁니다. 실제 터미널이 내보내지 않는 값이라
사설 신호로 안전합니다.

이렇게 키를 명시적으로 바인딩하면 `option_as_alt`를 켜지 않아도 되므로, `Option` 문자 조합(`å`, `ç`)이
그대로 유지됩니다. 시퀀스를 바꿀 때는 **두 파일을 모두** 고쳐야 합니다.

### 셸 알리아스

| 알리아스 | 실제 명령 |
| -------- | -------- |
| `l` | git 상태와 아이콘을 포함한 `eza` 목록 |
| `lt` | `eza` 트리, 2단계 깊이 |
| `c` | `z` (zoxide 점프) |
| `bat` | `bat -n --color=always --line-range :500` |
| `clean_cache` | `sudo ./delete_cache.sh` |
| `git ss` | `git status` |

### 그 외 동작

- **tmux 윈도우 이름 자동 변경** — `.zshrc`의 `chpwd` 훅이 디렉토리를 이동할 때마다 현재 tmux
  윈도우 이름을 그 폴더명으로 바꿉니다 (홈 디렉토리는 `~`).
- **`aws-login`** — AWS SSO 자격 증명을 갱신하고 CodeArtifact 토큰을 `.npmrc` / `.yarnrc`에
  기록한 뒤 해당 파일들을 `.gitignore`에 추가합니다. `package.json`이 있는 프로젝트 루트에서
  실행해야 합니다.
