# mpv configuration

This is my configuration for mpv and mpvnet media players.

Included scripts:

- [VR-reversal](https://github.com/dfaker/VR-reversal)

  _(This script's files are prefixed with `360plugin`)._

  This script enables interactive viewing of 360° videos.

  Toggle with `v`. Increase resolution with `y`, decrease with `h`. Toggle mouse
  look with left mouse button.

- [Thumbfast](https://github.com/po5/thumbfast) (Not currently working)

  High-performance on-the-fly thumbnailer for mpv.

- Movefile (own work)

  On keybind, moves the currently playing file to a `!mpv_movefile` directory in
  the same folder. Used for categorizing files while browsing.

  `Shift+Delete` to move the current file.

- Sleep Timer (own work)

  Quits mpv after a set time interval.

  `Y` to cycle through preset time intervals. `y` to show remaining time.

- Spawn New Instance (own work)

  Spawns a new instance of mpv/mpvnet with the currently playing file. Useful
  for quickly opening multiple videos while browsing through a directory.

  `Ctrl+n` to spawn a new instance.

- [mpv_sponsorblock_minimal](https://codeberg.org/jouni/mpv_sponsorblock_minimal)

  This is a simpler version of the mpv SponsorBlock plugin. This script only
  includes the sponsor skipping functionality.

  `b` to toggle skipping.

There is no automation for updating these scripts, so check their respective
repositories sometimes.
