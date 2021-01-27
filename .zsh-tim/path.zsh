# these paths will all be prepended to the $PATH variable in reverse order
# in other words, the paths at the end will be first in the $PATH variable
ADDITIONAL_PATHS=(
    "/usr/local/opt/gnu-tar/libexec/gnubin"
    "/usr/local/opt/bzip2/bin"
    "/usr/local/opt/coreutils/libexec/gnubin"
    "$HOME/.local/bin"
    "/usr/local/opt/zip/bin"
    "/usr/local/opt/rsync/bin"
    "/usr/local/opt/openssh/bin"
    "$HOME/.jenv/bin"
)


for additional_path ($ADDITIONAL_PATHS); do
    if [ -d $additional_path ]; then
        path=($additional_path $path)
    fi
done
export path
typeset -aU path