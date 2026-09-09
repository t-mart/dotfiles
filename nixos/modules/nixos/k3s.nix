{ config, lib, pkgs, ... }:
let
  cfg = config.roles.k3s;
in
{
  options.roles.k3s = {
    enable = lib.mkEnableOption "standalone k3s server";
    nodeLabels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    services.k3s = {
      enable = true;
      role = "server";
      clusterInit = false;
      extraFlags = map (label: "--node-label=${label}") cfg.nodeLabels;
    };

    environment.systemPackages = with pkgs; [
      fluxcd
      k3s
      kubectl
    ];

    networking.firewall = {
      allowedTCPPorts = [
        6443
        10250
      ];
      allowedUDPPorts = [ 8472 ];
    };

  };
}
