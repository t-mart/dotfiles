export ZSH_TIM_DIR="$HOME/.zsh-tim"

# add a function path
fpath=($ZSH_TIM_DIR/functions $ZSH_TIM_DIR/completions $fpath)

# Load all stock functions (from $fpath files) called below.
autoload -U compaudit compinit

# Add all plugins to fpath for compinit
for plugin ($ZSH_TIM_DIR/oh-my-zsh-plugins/*); do
    fpath=($plugin $fpath)
done

source $ZSH_TIM_DIR/oh-my-zsh-lib/compfix.zsh
# If completion insecurities exist, warn the user
handle_completion_insecurities
# Load only from secure directories
compinit -i -C -d "${ZSH_COMPDUMP}"

source "$ZSH_TIM_DIR/env.zsh"
source "$ZSH_TIM_DIR/zstyle.zsh"
source "$ZSH_TIM_DIR/path.zsh"
source "$ZSH_TIM_DIR/completion.zsh"
source "$ZSH_TIM_DIR/theme.zsh"
source "$ZSH_TIM_DIR/alias.zsh"

# Load all of the oh-my-zsh libraries
for lib_file ($ZSH_TIM_DIR/oh-my-zsh-lib/*.zsh); do
    source $lib_file
done

# Load all of the oh-my-zsh plugins
for plugin ($ZSH_TIM_DIR/oh-my-zsh-plugins/**/*.plugin.zsh); do
    source $plugin
done