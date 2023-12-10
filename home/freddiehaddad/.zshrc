# Start GUI
if [ -z "${DISPLAY}" ] && [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
	# exec systemd-cat --identifier=hyprland Hyprland
	# exec systemd-cat --identifier=sway sway
	exec systemd-cat --identifier=awesome startx /usr/bin/awesome
fi

# GPG Signing Key for GitHub
export GPG_TTY=$(tty)

# Completions
FILE="/usr/share/zsh/site-functions"
if [ -f "$FILE" ]; then
	fpath=("$FILE" $fpath)
fi

zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit
compinit

# History
HISTFILE="$HOME/.history"
HISTSIZE=10000
SAVEHIST=10000

# Fix directory colors
FILE="$HOME/.config/dircolors"
if [ -f "$FILE" ]; then
	eval "$(dircolors -b $FILE)"
fi

# Enable local bin
FILE="$HOME/.local/bin"
if [ -d "$FILE" ]; then
	PATH="$FILE:$PATH"
fi

# Arch specific
if (( $+commands[pacdiff] )); then
	export DIFFPROG="nvim -d"
fi

# Better history searching
if (( $+commands[fzf] )); then
	FILE="/usr/share/fzf/completions.zsh"
	if [ -f "$FILE" ]; then
		source "$FILE"
	fi

	FILE="/usr/share/fzf/key-bindings.zsh"
	if [ -f "$FILE" ]; then
		source "$FILE"
	fi
fi

# Autosuggestions
FILE="/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
if [ -f "$FILE" ]; then
	source "$FILE"
fi

# Syntax highlighting
FILE="/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if [ -f "$FILE" ]; then
	source "$FILE"
fi

# Vim mode
if (( $+commands[nvim] )); then
	bindkey -v
	export EDITOR=nvim
	alias vim="nvim"
fi

# Better ls
if (( $+commands[lsd] )); then
	if [ "$DISPLAY" ]; then
		alias ls="lsd"
	else
		alias ls="lsd --icon never"
	fi
	alias ll="ls -l"
	alias lla="ll -a"
fi

# Better cat
if (( $+commands[bat] )); then
	alias cat="bat --plain --theme ansi"
fi

# Better find
if (( $+commands[fd] )); then
	alias find="fd"
fi

# Better grep
if (( $+commands[rg] )); then
	alias grep="rg"
fi

# Fast directory switching
if (( $+commands[zoxide] )); then
	eval "$(zoxide init zsh)"
fi

# ASDF
FILE="$HOME/.asdf/asdf.sh"
if [ -f "$FILE" ]; then
	. "$HOME/.asdf/asdf.sh"

	# append completions to fpath
	fpath=(${ASDF_DIR}/completions $fpath)

	# initialise completions with ZSH's compinit
	autoload -Uz compinit && compinit
fi

# Pretty command prompt
if (( $+commands[starship] )); then
	eval "$(starship completions zsh)"
	eval "$(starship init zsh)"
fi

# Display splash
if (( $+commands[fastfetch] )) && [ -z "$TMUX" ]; then
	fastfetch
fi

