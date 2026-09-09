{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    autoPrune.enable = true;
  };

  users.users.tim.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker-buildx
    docker-compose
  ];

  home-manager.users.tim.imports = [ ../home/development.nix ];
}
