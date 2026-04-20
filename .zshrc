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

# Fix zsh-vi-mode + zsh-syntax-highlighting compatibility
zvm_after_init() {
  ZSH_HIGHLIGHT_MAX_LENGTH=300
}

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-vi-mode)

source $ZSH/oh-my-zsh.sh

# ----------------------------------------------------------------------------
# Path Configuration
# ----------------------------------------------------------------------------
# Add completion paths
fpath=("$HOME/.zsh/completions" $fpath)

# Development tools paths (guard against non-existent dirs + duplicate guard)
[[ -d "$HOME/nvim-macos/bin" ]] && case ":$PATH:" in *":$HOME/nvim-macos/bin:"*) ;; *) export PATH="$HOME/nvim-macos/bin:$PATH" ;; esac
export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL/bin" ]] && case ":$PATH:" in *":$BUN_INSTALL/bin:"*) ;; *) export PATH="$BUN_INSTALL/bin:$PATH" ;; esac
[[ -d "$HOME/go/bin" ]] && case ":$PATH:" in *":$HOME/go/bin:"*) ;; *) export PATH="$HOME/go/bin:$PATH" ;; esac
[[ -d "$HOME/zig" ]] && case ":$PATH:" in *":$HOME/zig:"*) ;; *) export PATH="$HOME/zig:$PATH" ;; esac

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
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
alias gb='git branch -a | fzf --preview="git log --oneline {1}" --bind="enter:execute(git checkout {1})+abort"'
alias gshow="git log --oneline | fzf --multi --preview 'git show {+1}' --bind='enter:execute(git show {+1})'"

# ----------------------------------------------------------------------------
# External Tool Initialization
# ----------------------------------------------------------------------------
# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Deno
[[ -f "$HOME/.deno/env" ]] && . "$HOME/.deno/env"

# ----------------------------------------------------------------------------
# PATH Cleanup — remove dead/obsolete directories
# ----------------------------------------------------------------------------
# Purge non-existent dirs from PATH to keep it lean
_clean_path=()
for _p in ${(s/:/)PATH}; do
  [[ -d "$_p" ]] && _clean_path+=("$_p")
done
export PATH="${(j/:/)_clean_path}"
unset _clean_path _p

# ----------------------------------------------------------------------------
# Completions
# ----------------------------------------------------------------------------
# OMZ already runs compinit, use -C to skip redundant security checks
autoload -Uz compinit && compinit -C

# Jujutsu completions (cached, regenerated daily)
_jj_completion_cache="${XDG_CACHE_HOME:-$HOME/.cache}/jj-completion.zsh"
if [[ ! -f "$_jj_completion_cache" || ( -f "$_jj_completion_cache" && -n "$(find "$_jj_completion_cache" -mtime +1 2>/dev/null)" ) ]]; then
  mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}"
  jj util completion zsh >! "$_jj_completion_cache" 2>/dev/null
fi
[[ -f "$_jj_completion_cache" ]] && source "$_jj_completion_cache"
