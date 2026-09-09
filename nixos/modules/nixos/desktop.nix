{ pkgs, ... }:
{
  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  security.rtkit.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  networking.networkmanager = {
    enable = true;
    settings.connectivity = {
      uri = "http://cp.cloudflare.com/";
      response = "";
      interval = 300;
    };
  };

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "tim" ];
    };
  };

  fonts.packages = with pkgs; [
    inter
    ibm-plex
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  environment.systemPackages = with pkgs; [
    ark
    ffmpegthumbs
    filelight
    firefox
    foliate
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kfind
    kitty
    libreoffice
    mpv
    qalculate-gtk
    signal-desktop
    vscode
    wl-clipboard
  ];

  home-manager.users.tim.imports = [ ../home/desktop.nix ];
}
