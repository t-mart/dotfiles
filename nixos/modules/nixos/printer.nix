{ pkgs, ... }:
{
  services.printing.drivers = [ pkgs.brlaser ];
}
