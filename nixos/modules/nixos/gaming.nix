{ ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs = {
    gamemode.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
