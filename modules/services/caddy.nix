{ config, ... }:
let
  lab = config.my.homelab;
  email = config.my.email;

  # Cloudflare API token for the DNS-01 challenge. Create this file manually (mode 600):
  #   CLOUDFLARE_API_TOKEN=<token with Zone:DNS:Edit on wallace.gg>
  tokenFile = "/etc/nixos/caddy-cloudflare.env";
in
{
  # Reverse proxy for every entry in my.homelab.services, behind one wildcard cert.
  # Certs come from Let's Encrypt via Cloudflare DNS, so nothing has to be exposed to the internet.
  flake.modules.nixos.caddy =
    { lib, pkgs, ... }:
    let
      upstream = svc: lab.hosts.${svc.host} or svc.host;

      routes = lib.concatStrings (
        lib.mapAttrsToList (name: svc: ''
          @${name} host ${svc.subdomain}.${lab.domain}
          handle @${name} {
            reverse_proxy ${upstream svc}:${toString svc.port}
          }

        '') lab.services
      );
    in
    {
      services.caddy = {
        enable = true;

        # On the first build Nix reports the real hash; paste it in place of lib.fakeHash.
        package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
          hash = lib.fakeHash;
        };

        environmentFile = tokenFile;
        email = email;

        virtualHosts."*.${lab.domain}".extraConfig = ''
          tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
            # Check the challenge record against public DNS, not the LAN resolver.
            resolvers 1.1.1.1
          }

          ${routes}
          # Unknown subdomain: drop the connection.
          handle {
            abort
          }
        '';
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
      # HTTP/3
      networking.firewall.allowedUDPPorts = [ 443 ];
    };
}
