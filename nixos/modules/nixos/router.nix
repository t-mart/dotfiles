{ config, lib, ... }:
let
  cfg = config.roles.router;
in
{
  options.roles.router = {
    enable = lib.mkEnableOption "router";
    wanInterface = lib.mkOption { type = lib.types.str; };
    lanInterface = lib.mkOption { type = lib.types.str; };
    lanAddress = lib.mkOption { type = lib.types.str; };
    lanSubnet = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      useDHCP = false;
      useNetworkd = true;
      networkmanager.enable = false;
      firewall.enable = false;
      nftables = {
        enable = true;
        checkRuleset = true;
        ruleset = ''
          table inet filter {
            chain input {
              type filter hook input priority filter; policy drop;
              ct state { established, related } accept
              iifname "lo" accept
              iifname "${cfg.lanInterface}" udp dport 53 accept
              iifname "${cfg.lanInterface}" tcp dport { 22, 53 } accept
              ip protocol icmp accept
              meta l4proto ipv6-icmp accept
            }

            chain forward {
              type filter hook forward priority filter; policy drop;
              ct state { established, related } accept
              iifname "${cfg.lanInterface}" oifname "${cfg.wanInterface}" accept
            }
          }

          table ip nat {
            chain postrouting {
              type nat hook postrouting priority srcnat; policy accept;
              oifname "${cfg.wanInterface}" ip saddr ${cfg.lanSubnet} masquerade
            }
          }
        '';
      };
    };

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    systemd.network = {
      enable = true;
      networks = {
        "10-wan" = {
          matchConfig.Name = cfg.wanInterface;
          networkConfig.DHCP = "yes";
        };
        "20-lan" = {
          matchConfig.Name = cfg.lanInterface;
          address = [ cfg.lanAddress ];
          networkConfig.ConfigureWithoutCarrier = true;
        };
      };
    };

    services.unbound = {
      enable = true;
      settings = {
        server = {
          interface = [
            "127.0.0.1"
            "::1"
            (builtins.head (lib.splitString "/" cfg.lanAddress))
          ];
          access-control = [
            "127.0.0.0/8 allow"
            "::1 allow"
            "${cfg.lanSubnet} allow"
          ];
          hide-identity = true;
          hide-version = true;
        };
      };
    };
  };
}
