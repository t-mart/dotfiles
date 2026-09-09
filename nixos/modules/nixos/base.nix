{ lib, pkgs, ... }:
let
  authorizedKeys = import ../../keys/tim.keys.nix;
in
{
  boot = {
    initrd.systemd.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false;
      };
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "tim"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  networking.firewall.enable = lib.mkDefault true;
  networking.useDHCP = lib.mkDefault true;

  services = {
    fstrim.enable = true;
    openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  programs.nushell.enable = true;

  users.users.tim = {
    isNormalUser = true;
    description = "Tim Martin";
    shell = pkgs.nushell;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = authorizedKeys;
  };

  security.sudo.wheelNeedsPassword = true;

  environment.systemPackages = with pkgs; [
    age
    btop
    curl
    duf
    git
    gnupg
    jq
    lnav
    neovim
    ripgrep
    rsync
    unzip
    vim
    yq-go
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  warnings = lib.optional (authorizedKeys == [ ]) (
    "No SSH keys exist in keys/tim.keys.nix. Add keys before a fresh or remote installation."
  );
}
