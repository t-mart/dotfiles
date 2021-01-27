setopt PROMPT_SUBST
setopt PROMPT_PERCENT
autoload -Uz vcs_info add-zsh-hook promptinit
promptinit

# creates a prompt segment with visual effects
# usage: tim_prompt_color <value> [--fg <color>] [--bg <color>] [--underline] [--bold]
tim_prompt_color() {
  local opt pos fg bg underline bold

  value=$1
  shift

  # this is probably an abuse of
  zparseopts -A opt -a pos -fg:: -bg:: -underline -bold

  fg="${opt[--fg]}"
  bg="${opt[--bg]}"
  underline=${pos[(Ie)--underline]}
  bold=${pos[(Ie)--bold]}

  local out="%{"

  if [[ -n $fg ]]; then
    out="${out}%F{$fg}"
  fi

  if [[ -n $bg ]]; then
    out="${out}%K{$bg}"
  fi

  if (( $underline )); then
    out="${out}%U"
  fi

  if (( $bold )); then
    out="${out}%B"
  fi

  out="${out}%}$value%{"

  if [[ -n $fg ]]; then
    out="${out}%f"
  fi

  if [[ -n $bg ]]; then
    out="${out}%k"
  fi

  if (( $underline )); then
    out="${out}%u"
  fi

  if (( $bold )); then
    out="${out}%b"
  fi

  out="${out}%}"

  echo -n $out
}

# d3 category 10
ZSH_THEME_BLUE="#1f77b4"
ZSH_THEME_ORANGE="#ff7f0e"
ZSH_THEME_GREEN="#2ca02c"
ZSH_THEME_RED="#d62728"
ZSH_THEME_PURPLE="#9467bd"
ZSH_THEME_BROWN="#8c564b"
ZSH_THEME_PINK="#e377c2"
ZSH_THEME_GREY="#7f7f7f"
ZSH_THEME_YELLOW="#bcbd22"
ZSH_THEME_CYAN="#17becf"

# the below section sets formats for git_prompt_status, which
# gives indicates various things about the git state
# ZSH_THEME_GIT_PROMPT_UNTRACKED="(untracked)"
ZSH_THEME_GIT_PROMPT_UNTRACKED="$(tim_prompt_color "*" --bold --fg $ZSH_THEME_YELLOW)"
ZSH_THEME_GIT_PROMPT_ADDED="$(tim_prompt_color "+" --bold --fg $ZSH_THEME_GREEN)"
ZSH_THEME_GIT_PROMPT_MODIFIED="$(tim_prompt_color "Δ" --bold --fg $ZSH_THEME_YELLOW)"
ZSH_THEME_GIT_PROMPT_RENAMED="$(tim_prompt_color "⟳" --bold --fg $ZSH_THEME_YELLOW)"
ZSH_THEME_GIT_PROMPT_DELETED="$(tim_prompt_color "-" --bold --fg $ZSH_THEME_RED)"
ZSH_THEME_GIT_PROMPT_UNMERGED="$(tim_prompt_color "↣" --bold --fg $ZSH_THEME_RED)"
ZSH_THEME_GIT_PROMPT_AHEAD="$(tim_prompt_color "(ahead)" --bold --fg $ZSH_THEME_GREY)"
ZSH_THEME_GIT_PROMPT_BEHIND="$(tim_prompt_color "(behind)" --bold --fg $ZSH_THEME_GREY)"
ZSH_THEME_GIT_PROMPT_DIVERGED="$(tim_prompt_color "(diverged)" --bold --fg $ZSH_THEME_GREY)"
ZSH_THEME_GIT_PROMPT_STASHED="$(tim_prompt_color "↓" --bold --fg $ZSH_THEME_GREY)"

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' actionformats '%b|%a'
zstyle ':vcs_info:*' formats '%b'

set_terminal_title() {
  print -Pn "\e]0;%n@%M %~\a"
}

# precmd is called before prompt is drawn, preexec before each command is run
# instead of overwriting precmd() and preexec(), we can hook into those
# functions to also call our custom code. this is slightly better because
# we preserve any previously-set precmd/preexec functionality.
add-zsh-hook precmd set_terminal_title
add-zsh-hook precmd vcs_info

# === vi normal mode indicator on rprompt.
# Updates editor information when the keymap changes.
function zle-keymap-select() {
  # update keymap variable for the prompt
  VI_KEYMAP=$KEYMAP

  zle reset-prompt
  zle -R
}

zle -N zle-keymap-select

function vi-accept-line() {
  VI_KEYMAP=main
  zle accept-line
}

zle -N vi-accept-line

function vi_mode_prompt_info() {
  local mode_indictor="$(tim_prompt_color "-- NORMAL --" --fg $ZSH_THEME_YELLOW --bold)"
  echo "${${VI_KEYMAP/vicmd/$mode_indictor}/(main|viins)/}"
}
# === End of vi normal mode indicator

prompt_jobs() {
  local job_count=$(jobs -l | wc -l)

  tim_prompt_color "◔${job_count}" --bold --fg $ZSH_THEME_GREY
}

prompt_path() {
  tim_prompt_color "%~" --underline --bold --fg $ZSH_THEME_BLUE
}

prompt_user_at_host() {
  tim_prompt_color "%n" --bold --fg $ZSH_THEME_PINK
  tim_prompt_color "@"
  tim_prompt_color "%M" --bold --fg $ZSH_THEME_PINK
}

prompt_date() {
  tim_prompt_color "%D{%FT%T%Z}" --bold
}

prompt_exit_status() {
  # will be passed exit status as arg $1
  tim_prompt_color "↳" --bold
  if (( $TIM_PROMPT_EXIT_STATUS )); then  # if exit status is non-zero
    tim_prompt_color "$TIM_PROMPT_EXIT_STATUS" --fg $ZSH_THEME_RED --bold
  else
    tim_prompt_color "$TIM_PROMPT_EXIT_STATUS" --fg $ZSH_THEME_GREEN --bold
  fi
}

prompt_privilege_level() {
  if (( $UID == 0 || $EUID == 0 )); then
    tim_prompt_color "#" --fg $ZSH_THEME_RED --bold
  else
    tim_prompt_color "%%" --fg $ZSH_THEME_GREEN --bold
  fi
}

prompt_git() {
  # here, we use a combination of zsh's vcs_info and oh-my-zsh's more verbose
  # status.
  if [[ -n "${vcs_info_msg_0_}" ]]; then
    tim_prompt_color "${vcs_info_msg_0_}" --fg $ZSH_THEME_ORANGE --bold
    if [[ -n "$(git_prompt_status)" ]]; then
      tim_prompt_color ":"
      tim_prompt_color "$(git_prompt_status)" --fg $ZSH_THEME_ORANGE --bold
    fi
  fi
}

build_prompt() {
  # It's essential that the exit status is captured early
  # precmd seems to be like a closure when it comes to exit status, where
  # 1. the exit status from normal interaction is set initially,
  # 2. the exit status will change if to that of functions run inside precmd
  # 3. the original exit status is restored when leaving the function
  # local normal_exit_status=$?
  TIM_PROMPT_EXIT_STATUS=$?

  # whitespace is important here
  # first, I want a newline before each prompt
  # secondly, subsequent lines need to be all the way left-justified so
  # there are no leading spaces.
  echo -n "
$(prompt_user_at_host) $(prompt_date) $(prompt_jobs) $(prompt_git)
$(prompt_path) $(prompt_exit_status) $(prompt_privilege_level) "
}

# yikes. prompts formats (PS1, PS2, etc) that contain function calls will only
# re-call those functions if the prompt is defined with SINGLE QUOTES.
#
# this doesn't seem to be a problem for the prompt expansions (e.g. %M for host,
# %D for date), but if there are _functions_ in the prompt like $(myfunc), then
# the function will not get recalled beyond the first prompt.
#
# see comments at https://unix.stackexchange.com/a/32151/412723:
#  "Double quotes will expand $GREETING on assignment, i.e. PROMPT will be set to a
#   fixed string. With single quotes, PROMPT will contain the string $GREETING,
#   which will then be reevaluated to the value of $GREETING on every new line,
#   thanks to prompt_subst"
PS1='$(build_prompt)'

RPS1='$(vi_mode_prompt_info)'

