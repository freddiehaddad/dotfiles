# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep extendedglob nomatch notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/freddiehaddad/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Add .local/bin to path
export PATH="$HOME/.local/bin:$PATH"

# Alias
if (( $+commands[lsd] )); then
  alias ls=lsd
fi

if (( $+commands[fzf] )); then
  # Base16 default dark
  local color00='#181818'
  local color01='#282828'
  local color02='#383838'
  local color03='#585858'
  local color04='#b8b8b8'
  local color05='#d8d8d8'
  local color06='#e8e8e8'
  local color07='#f8f8f8'
  local color08='#ab4642'
  local color09='#dc9656'
  local color0A='#f7ca88'
  local color0B='#a1b56c'
  local color0C='#86c1b9'
  local color0D='#7cafc2'
  local color0E='#ba8baf'
  local color0F='#a16946'

  export FZF_DEFAULT_OPTS="--color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D,fg:$color04,header:$color0D,info:$color0A,pointer:$color0C,marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D"
fi

if (( $+commands[bat] )); then
  export BAT_THEME="base16"
  alias cat=bat
fi

if (( $+commands[nvim] )); then
  alias vim=nvim
  alias nvim=nvim
  export EDITOR='nvim'
fi

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

# Powerlevel 10k
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Cargo
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# Zoxide
if [ -f "$HOME/.local/bin/zoxide" ]; then
  eval "$(zoxide init zsh)"
fi

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# PyEnv
if [ -f "$HOME/.pyenv/bin/pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi
