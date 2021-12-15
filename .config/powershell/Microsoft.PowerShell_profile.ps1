function dfgit {
    git --git-dir=$HOME/.dotfile_config/ --work-tree=$HOME $args
}

Invoke-Expression (&starship init powershell)
