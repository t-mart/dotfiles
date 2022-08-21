# Fan Control Config

This directory store configuration for [Fan Control](https://github.com/Rem0o/FanControl.Releases),
a hardware fan control application for Windows.

At the time of writing, Fan Control is not on scoop, so I extracted a release (from above) into my
`~/.local` directory.

From there, I symlinked this `userConfig.json` to the application directory. (That's another problem
as of now: you gotta place the configuration in the same directory as the executable).
