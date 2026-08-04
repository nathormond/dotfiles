#!/bin/zsh

# Enable Powerlevel10k instant prompt. Must stay at the very top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Dedup PATH on every assignment so re-sourcing this file doesn't stack duplicate entries
typeset -U path

# =========================================================
# Section 1: Environment & PATH
# =========================================================
export DOTFILES="$HOME/Dev/dotfiles"
export DEV="$HOME/Dev"
export HDS="$DEV/HDS"
export NOTES="$HOME/Documents/obsidian-vault"

if [[ "$(uname)" == "Darwin" ]]; then
    export PLATFORM="mac"
elif [[ "$(uname)" == "Linux" ]]; then
    export PLATFORM="linux"
else
    export PLATFORM="unknown"
fi

# Set TERM for tmux sessions
if [[ -n "$TMUX" ]]; then
  export TERM="tmux-256color"
fi

# Homebrew environment
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
    export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
elif [[ -x "/usr/local/bin/brew" ]]; then
    export PATH="/usr/local/bin:$PATH"
fi

if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

# Go Environment
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$PATH:$GOPATH/bin

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/emulator

# User Local Bins
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"

export SSH_AUTH_SOCK=~/.1password/agent.sock

# =========================================================
# Section 2: Zinit Plugin Manager & Theme
# =========================================================
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33}Installing Zinit Initiative Plugin Manager..."
    command mkdir -p "$HOME/.local/share/zinit" && \
    command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33}Installation successful.%f%b" || \
        print -P "%F{160}The clone has failed.%f%b"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light romkatv/powerlevel10k
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# =========================================================
# Section 3: Completion and History
# =========================================================
# Fast compinit with dump check
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.m+1) ]]; then
  compinit
else
  compinit -C
fi

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:default' list-colors '=*=90'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY

alias hr='fc -RI'
alias history='fc -li 1'

# =========================================================
# Section 4: Aliases & External Tools
# =========================================================
alias please='sudo'
alias cdev='cd $DEV'
alias cdev-hds='cd $HDS'
alias cdotfiles='cd $DEV/dotfiles'
alias c='clear'
alias hgrep="history | grep"
alias notes='cd $NOTES'
alias notes-push='git add . && git commit -m "notes: $(date +%Y-%m-%d)" && git push'
alias copy="pbcopy"
alias paste="pbpaste"
alias write-secrets='$EDITOR ~/afterzsh/aliases.sh'

export LOCAL_SECRETS="$HOME/afterzsh"
if [[ -f "$LOCAL_SECRETS/aliases.sh" ]]; then
    source "$LOCAL_SECRETS/aliases.sh"
fi

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#999999"

# Google Cloud SDK
if [ -d "/opt/homebrew/share/google-cloud-sdk" ]; then
    [ -f "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc" ] && source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
    [ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ] && source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
fi

# Conda (Lazy-loaded on demand if installed, preventing pollution of PATH/virtualenvs for Poetry & Pyenv)
for _conda_path in \
    "$HOME/miniconda3/bin/conda" \
    "$HOME/anaconda3/bin/conda" \
    "/opt/homebrew/Caskroom/miniconda/base/bin/conda" \
    "/opt/homebrew/anaconda3/bin/conda"; do
    if [ -f "$_conda_path" ]; then
        CONDA_EXE="$_conda_path"
        conda() {
            unset -f conda
            eval "$("$CONDA_EXE" 'shell.zsh' 'hook' 2> /dev/null)"
            conda "$@"
        }
        break
    fi
done
unset _conda_path

# Pyenv initialization (Fixed invalid --install flag)
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT/bin ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
elif command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# NVM initialization
export NVM_DIR="$HOME/.nvm"
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    source "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi
