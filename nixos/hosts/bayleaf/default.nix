{ ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/k3s.nix
  ];

  networking.hostName = "bayleaf";

  roles.k3s = {
    enable = true;
    nodeLabels = [ "node.kubernetes.io/purpose=homelab" ];
  };

  system.stateVersion = "26.05";
}
