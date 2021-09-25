# has dependency on pyenv, needs to run after that

if (( $+commands[pip] )) then;
    eval "$(pip completion --zsh)"
fi
