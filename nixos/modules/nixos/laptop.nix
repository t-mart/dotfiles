{ ... }:
{
  services = {
    fwupd.enable = true;
    power-profiles-daemon.enable = true;
    thermald.enable = false;
  };

  powerManagement.enable = true;
}
