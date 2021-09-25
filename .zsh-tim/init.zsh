export ZSH_TIM_DIR="$HOME/.zsh-tim"

# Set to 1 to enable profiling
ENABLE_ZSH_PROFILING=0
# See https://stevenvanbael.com/profiling-zsh-startup for tutorial
if [ "$ENABLE_ZSH_PROFILING" -eq 1 ]; then
    zmodload zsh/zprof
fi

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
source "$ZSH_TIM_DIR/theme.zsh"
source "$ZSH_TIM_DIR/alias.zsh"

# Source all the tool setup files
for tool_setup_file ($ZSH_TIM_DIR/tools/*.zsh); do
    source $tool_setup_file
done

# Load all of the oh-my-zsh libraries
for lib_file ($ZSH_TIM_DIR/oh-my-zsh-lib/*.zsh); do
    source $lib_file
done

# Load all of the oh-my-zsh plugins
for plugin ($ZSH_TIM_DIR/oh-my-zsh-plugins/**/*.plugin.zsh); do
    source $plugin
done

if [ "$ENABLE_ZSH_PROFILING" -eq 1 ]; then
    zprof
fi