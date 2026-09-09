{ lib, pkgs, ... }:
let
  keyboardBacklightd =
    if builtins.hasAttr "keyboard-backlightd" pkgs then
      builtins.getAttr "keyboard-backlightd" pkgs
    else
      null;
in
{
  boot.kernelModules = [ "thinkpad_acpi" ];

  services.thinkfan = {
    enable = true;
    sensors = [
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "k10temp";
        indices = [ 1 ];
      }
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "amdgpu";
        indices = [ 1 ];
      }
    ];
    fans = [
      {
        type = "tpacpi";
        query = "/proc/acpi/ibm/fan";
      }
    ];
    levels = [
      [
        0
        0
        50
      ]
      [
        "level auto"
        45
        75
      ]
      [
        "level disengaged"
        70
        255
      ]
    ];
  };

  environment = {
    etc."conf.d/keyboard-backlightd".text = ''
      INPUTS=-i /dev/input/by-path/platform-i8042-serio-0-event-kbd \
             -i /dev/input/by-path/platform-thinkpad_acpi-event \
             -i /dev/input/by-path/platform-i8042-serio-1-event-mouse \
             -i /dev/input/by-path/platform-AMDI0010:02-event-mouse \
             -i /dev/input/by-path/platform-AMDI0010:01-event
      LED=/sys/class/leds/tpacpi::kbd_backlight
      BRIGHTNESS=1
      TIMEOUT=7500
      WAIT=15000
      FLAGS=
      RUST_LOG=warn
    '';
    systemPackages = with pkgs; [
      evtest
      lm_sensors
      wireless-regdb
    ] ++ lib.optional (keyboardBacklightd != null) keyboardBacklightd;
  };

  systemd.packages = lib.optional (keyboardBacklightd != null) keyboardBacklightd;
  systemd.services.keyboard-backlightd = lib.mkIf (keyboardBacklightd != null) {
    wantedBy = [ "multi-user.target" ];
  };

  warnings = lib.optional (keyboardBacklightd == null) (
    "Nixpkgs lacks keyboard-backlightd. Add a local package before deploying lemongrass."
  );
}
