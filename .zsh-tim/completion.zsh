if (( $+commands[pip] )) then;
    eval "$(pip completion --zsh)"
fi

if (( $+commands[jenv] )) then;
    eval "$(jenv init -)"
fi

if (( $+commands[pyenv] )) then;
    eval "$(pyenv init -)"
fi

if (( $+commands[fly] )) then;
    eval "$(fly completion --shell=zsh)"
fi