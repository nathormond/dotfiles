#!/bin/zsh

# =========================================================
# Section 1: Zinit Setup & Powerlevel10k Theme
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
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
zinit light romkatv/powerlevel10k
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
source ~/.p10k.zsh

# =========================================================
# Section 1.1: Completion and History
# =========================================================
# Initialize the completion system
autoload -Uz compinit && compinit

# Completion styling - enable menu selection with highlighting
zstyle ':completion:*' menu select                              # Enable menu selection
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Use LS_COLORS for file completions
zstyle ':completion:*:*:*:*:default' list-colors '=*=90'        # Dim color for non-selected items
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'             # Case-insensitive matching
zstyle ':completion:*' special-dirs true                        # Complete . and .. directories
zstyle ':completion:*' group-name ''                            # Group completions by type
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=100000                    # Commands to keep in memory
SAVEHIST=100000                    # Commands to save to file

setopt EXTENDED_HISTORY            # Write timestamps to history
setopt HIST_EXPIRE_DUPS_FIRST      # Expire duplicate entries first when trimming
setopt HIST_IGNORE_DUPS            # Don't record consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS        # Delete old duplicate when new one is added
setopt HIST_IGNORE_SPACE           # Don't record commands starting with space
setopt HIST_FIND_NO_DUPS           # Don't show duplicates when searching
setopt HIST_SAVE_NO_DUPS           # Don't write duplicates to file
setopt HIST_VERIFY                 # Show command before executing from history
setopt SHARE_HISTORY               # Share history across all sessions (reads & writes)
setopt APPEND_HISTORY              # Append to history file, don't overwrite

# Force history reload - useful keybinding for tmux users
alias hr='fc -RI'                  # Reload history from file into current session
alias history='fc -li 1'           # Show all history with timestamps by default


# =========================================================
# Section 2: Core Configuration
# =========================================================
print_status() {
    local component=$1
    local state=$2
    if [ "$state" = "enabled" ]; then
        echo "\033[0;32m✓ $component configured\033[0m"
    else
        echo "\033[0;31m✗ $component not found\033[0m"
    fi
}

#check_vim_clipboard() {
#    if [[ "$(uname)" == "Linux" ]]; then
#        if command -v vim >/dev/null 2>&1; then
#            if ! vim --version | grep -q '+clipboard'; then
#                echo "📋 Vim does not have clipboard support. Installing vim-gtk3..."
#                sudo apt-get update && sudo apt-get install -y vim-gtk3
#                echo "✅ Installed vim with clipboard support."
#            fi
#        fi
#    fi
#}
export DOTFILES="$HOME/Dev/dotfiles"
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
if [[ -x "/opt/homebrew/bin/brew" ]] || [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    source "/opt/homebrew/opt/nvm/nvm.sh"
    source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$PATH:$GOPATH/bin
if [ -d "/opt/homebrew/share/google-cloud-sdk" ]; then
    if [ -f "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc" ]; then
        source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
    fi
    if [ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ]; then
        source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
    fi
fi
if [ -f "/opt/homebrew/Caskroom/miniconda/base/bin/conda" ]; then
    __conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
            . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
        else
            export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
        fi
    fi
    unset __conda_setup
fi
export LOCAL_SECRETS="$HOME/afterzsh"
if [[ -f "$LOCAL_SECRETS/aliases.sh" ]]; then
    source "$LOCAL_SECRETS/aliases.sh"
fi
export DEV="$HOME/Dev"
export REEL="$DEV/reelables"
export NOTES="/Users/$USER/Documents/obsidian-vault"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export SSH_AUTH_SOCK=~/.1password/agent.sock
alias please='sudo'
alias cdev='cd $REEL'
alias edh='cd $REEL/edge-data-hub'
alias dev='cd $'
alias cdotfiles='cd $DEV/dotfiles'
alias c='clear'
alias hgrep="history | grep"
alias notes='cd $NOTES'
alias notes-push='git add . && git commit -m "notes: $(date +%Y-%m-%d)" && git push'
alias copy="pbcopy"
alias paste="pbpaste"
alias write-secrets='$EDITOR ~/afterzsh/aliases.sh'
export SSH_AUTH_SOCK=~/.1password/agent.sock
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#999999"

# =========================================================
# Section 3: Status Messages (Console Output)
# =========================================================
echo "\n🔧 Loading configurations..."
print_status "Platform detection ($PLATFORM)" "enabled"
print_status "Homebrew" "enabled"
print_status "Node Version Manager" "enabled"
if command -v $EDITOR >/dev/null 2>&1; then
    print_status "Editor ($EDITOR)" "enabled"
else
    print_status "Editor ($EDITOR)" "disabled"
fi
if command -v go >/dev/null 2>&1; then
    print_status "Go" "enabled ($(go version))"
else
    print_status "Go" "disabled"
fi
if [ -d "/opt/homebrew/share/google-cloud-sdk" ]; then
    print_status "Google Cloud SDK" "enabled"
else
    print_status "Google Cloud SDK" "disabled"
fi
if [ -f "/opt/homebrew/Caskroom/miniconda/base/bin/conda" ]; then
    print_status "Conda" "enabled"
else
    print_status "Conda" "disabled"
fi
if [ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]; then
    print_status "Zinit" "enabled"
else
    print_status "Zinit" "disabled"
fi
if [[ -f "$LOCAL_SECRETS/aliases.sh" ]]; then
    print_status "Custom Aliases" "enabled"
else
    print_status "Custom Aliases" "disabled"
fi
if [[ -d "$DOTFILES" ]]; then
    if [[ ! -L "$HOME/.zshrc" || "$(readlink "$HOME/.zshrc")" != "$DOTFILES/.zshrc" ]]; then
        echo "Dotfiles need to be installed. Running install script..."
        if [[ -f "$DOTFILES/install.sh" ]]; then
            chmod +x "$DOTFILES/install.sh"
            "$DOTFILES/install.sh"
        fi
    fi
#    check_vim_clipboard
fi
echo "\n✨ Configuration loading complete\n"
export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity
export PATH="/Users/nathanormond/.antigravity/antigravity/bin:$PATH"
