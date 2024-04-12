# foobar2000 dotfiles

I maintain my [Foobar2000](https://www.foobar2000.org/) theme configuration in
this subdirectory.

Foobar2000 is a little weird in that, for `theme.fth`, on exit, it deletes the file
and then writes a new one with the current configuration. This means that I can't
just symlink the file to the dotfiles directory, as it would be deleted on exit.

Deploying the theme with `rotz link` works just fine, but I have to remember that,
when I make changes in Foobar2000 to it, I need to copy that file back here.
