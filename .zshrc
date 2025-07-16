# ============================================================================
# ZSH CONFIGURATION
# ============================================================================

# ----------------------------------------------------------------------------
# Instant Prompt & Theme Setup
# ----------------------------------------------------------------------------
# Enable Powerlevel10k instant prompt (must be near top of .zshrc)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----------------------------------------------------------------------------
# Oh My Zsh Configuration
# ----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Auto-update settings
zstyle ':omz:update' mode auto

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-vi-mode)

source $ZSH/oh-my-zsh.sh

# ----------------------------------------------------------------------------
# Path Configuration
# ----------------------------------------------------------------------------
# Add completion paths
if [[ ":$FPATH:" != *":/Users/jesusmarin/.zsh/completions:"* ]]; then
  export FPATH="/Users/jesusmarin/.zsh/completions:$FPATH"
fi

# Development tools paths
export PATH="$HOME/nvim-macos/bin/:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH:$HOME/go/bin:$HOME/zig/"

# pnpm
export PNPM_HOME="/Users/jesusmarin/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ----------------------------------------------------------------------------
# Tool Configuration
# ----------------------------------------------------------------------------
# FZF Configuration
export FZF_DEFAULT_COMMAND="fd --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--style full --border"
export FZF_CTRL_R_OPTS="--border-label='Personalyisus: Command finder'"
export FZF_CTRL_T_OPTS="--border-label='Personalyisus: Files finder'"
export FZF_ALT_C_OPTS="--border-label='Personalyisus: Folder navigator'"

# Ripgrep configuration
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# ----------------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------------
alias top="glances"
alias ls="eza"
alias gb="git branch | fzf --preview=\"git log --oneline {+1}\""
alias gshow="git log --oneline | fzf --multi --preview 'git show {+1}' --bind='enter:execute(git show {+1})'"

# ----------------------------------------------------------------------------
# External Tool Initialization
# ----------------------------------------------------------------------------
# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Bun
[ -s "/Users/jesusmarin/.bun/_bun" ] && source "/Users/jesusmarin/.bun/_bun"

# Deno
. "/Users/jesusmarin/.deno/env"

# ----------------------------------------------------------------------------
# Completions
# ----------------------------------------------------------------------------
autoload -Uz compinit
compinit

# Jujutsu completions
source <(jj util completion zsh)
