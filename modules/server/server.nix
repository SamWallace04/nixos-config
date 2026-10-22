{ config, ... }:
let
  lab = config.my.homelab;
in
{
  # Headless server defaults: static IP from my.homelab.hosts.<hostName>, firewall on, no NetworkManager.
  flake.modules.nixos.server =
    { config, lib, ... }:
    let
      hostName = config.networking.hostName;
    in
    {
      assertions = [
        {
          assertion = lab.hosts ? ${hostName};
          message = "server: add '${hostName}' to my.homelab.hosts in modules/homelab/homelab.nix";
        }
      ];

      networking.networkmanager.enable = lib.mkForce false;
      networking.useDHCP = false;
      networking.nameservers = lab.nameservers;
      networking.firewall.enable = true;

      systemd.network = {
        enable = true;
        # Matches the virtio NIC whatever it ends up being called (ens3, enp0s3, ...).
        networks."10-lan" = {
          matchConfig.Name = "en* eth*";
          address = [ "${lab.hosts.${hostName} or "0.0.0.0"}/${toString lab.prefixLength}" ];
          gateway = [ lab.gateway ];
          linkConfig.RequiredForOnline = "routable";
        };
      };

      documentation.nixos.enable = false;

      # Lets tailnet peers connect directly instead of relaying through DERP.
      services.tailscale.openFirewall = lib.mkIf config.services.tailscale.enable true;
    };

  # A self-contained shell for servers (sam-pc's zsh setup links to a dotfiles checkout).
  flake.modules.homeManager.server-shell = {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
    programs.starship.enable = true;
  };
}
