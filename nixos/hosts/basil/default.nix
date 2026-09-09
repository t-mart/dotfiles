{ ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/k3s.nix
  ];

  networking.hostName = "basil";

  roles.k3s = {
    enable = true;
    nodeLabels = [ "node.kubernetes.io/purpose=remote" ];
  };

  system.stateVersion = "26.05";
}
