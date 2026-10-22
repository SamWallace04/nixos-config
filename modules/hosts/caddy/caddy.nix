{ inputs, config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
  username = config.my.username;
  lab = config.my.homelab;
in
{
  # TrueNAS VM: reverse proxy for the other homelab VMs (see modules/homelab/homelab.nix).
  flake.nixosConfigurations.caddy = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.home-manager.nixosModules.home-manager

      nixos.truenas-guest
      nixos.nix-settings
      nixos.base
      nixos.server
      nixos.user
      nixos.zsh
      nixos.caddy
      nixos.tailscale
      {
        networking.hostName = "caddy";
        # Match the value in the /etc/nixos/configuration.nix the installer generated.
        system.stateVersion = "26.05";

        # *.home.wallace.gg resolves to Caddy's LAN IP. Advertising just that one address to the
        # tailnet makes the same URLs work away from home (approve the route once in the
        # Tailscale admin console), without exposing anything to the internet.
        services.tailscale = {
          useRoutingFeatures = "server";
          extraSetFlags = [ "--advertise-routes=${lab.hosts.caddy}/32" ];
        };

        home-manager.users.${username} = {
          imports = with homeManager; [
            user
            server-shell
            git
            cli-tools
          ];
          home.stateVersion = "26.05";
        };
      }
    ];
  };
}
