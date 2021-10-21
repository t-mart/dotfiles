# My fish config

#############
# Theme stuff
#############

# d3 category 10 colors
set d3_blue "#1f77b4"
set d3_orange "#ff7f0e"
set d3_green "#2ca02c"
set d3_red "#d62728"
set d3_purple "#9467bd"
set d3_brown "#8c564b"
set d3_pink "#e377c2"
set d3_grey "#7f7f7f"
set d3_yellow "#bcbd22"
set d3_cyan "#17becf"

set __fish_git_prompt_show_informative_status true
set __fish_git_prompt_color $d3_orange

function fish_prompt --description "Write out my prompt"

    # immediately capture exit code of user's last command (otherwise, this function will clobber)
    set -l _status $status

    # helper function to add color code, value, and reset color code.
    function _colorize --description "Print a string (arg 1) with styling from set_color. All args[2..] are passed to set_color. Normal color reset after printing value"
        printf '%s%s%s' (set_color $argv[2..]) (echo $argv[1]) (set_color normal)
    end

    # format:
    # <user>@<host> <datetime> <gitstuff>
    # <pwd> ↳<exitcode> <privlevelsymbol>
    printf '\n%s@%s %s%s\n%s ↳%s %s ' \
        (_colorize $USER --bold $d3_pink) \
        (_colorize $hostname --bold $d3_pink) \
        (_colorize (date --iso-8601=seconds) --bold) \
        (fish_git_prompt; or echo "") \
        (_colorize $PWD --underline --bold $d3_blue) \
        (_colorize $_status --bold (test $_status -eq 0; and echo $d3_green; or echo $d3_red)) \
        (fish_is_root_user; and _colorize "#" --bold $d3_red; or _colorize "%" --bold $d3_green)
end

#######################
# Environment Variables
#######################

# set up locale stuff
set -gx LC_ALL en_US.UTF-8
set -gx LANG en_US.UTF-8
set -gx LANGUAGE en_US.UTF-8

# set up XDG Base Directory Specification stuff
# defaults from https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
# in the "Environment Variables section"
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_STATE_HOME $HOME/.local/state

# ls uses this to color specific types of dir contents
set -gx LS_COLORS 'rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';

# set editor. used by git for interactive commit messages, etc
set -gx EDITOR 'vim'

# no prompt mucking for virtual envs
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1

###############
# Special Paths
###############

fish_add_path $HOME/.local/bin

#########
# Aliases
#########

alias dfgit "git --git-dir=$HOME/.dotfile_config/ --work-tree=$HOME"

###########
# CLI Tools
###########

# jenv
# the below might be sufficient, but there's additional stuff to try
# at https://github.com/jenv/jenv
set -gx JENV_ROOT $HOME/.jenv
if test -d $JENV_ROOT
    fish_add_path $JENV_ROOT/bin
    jenv init - | source
else
    set -ge JENV_ROOT
end

# nvm
set -gx NVM_DIR $XDG_CONFIG_HOME/nvm
if test -d $NVM_DIR
    function nvm
        bass source $NVM_DIR/nvm.sh --no-use ';' nvm $argv
    end
else
    set -ge NVM_DIR
end

# pyenv
set -gx PYENV_ROOT $HOME/.pyenv
if test -d $PYENV_ROOT
    fish_add_path $PYENV_ROOT/bin
    fish_add_path $PYENV_ROOT/shims
    pyenv init - | source
else
    set -ge PYENV_ROOT
end

# pip completions
# this depends on pyenv
if type -q pip
    pip completion --fish | source
end
