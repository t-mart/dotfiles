{ pkgs, ... }:
{
  home.packages = with pkgs; [
    qimgv
  ];

  programs = {
    kitty.enable = true;
    mpv.enable = true;
  };

  xdg = {
    enable = true;
    userDirs.enable = true;
  };
}
