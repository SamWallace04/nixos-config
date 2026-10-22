{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  # Flake-level description of the homelab: addresses of the TrueNAS VMs and which
  # services Caddy should proxy. Read from any file via `config.my.homelab`.
  options.my.homelab = {
    # Caddy serves https://<subdomain>.<domain> with one wildcard cert (*.<domain>).
    domain = mkOption {
      type = types.str;
      default = "home.wallace.gg";
    };

    nasAddress = mkOption {
      type = types.str;
      default = "192.168.1.214";
    };

    # LAN settings for the statically addressed server VMs.
    gateway = mkOption {
      type = types.str;
      default = "192.168.1.1";
    };
    prefixLength = mkOption {
      type = types.int;
      default = 24;
    };
    nameservers = mkOption {
      type = types.listOf types.str;
      default = [ "192.168.1.1" ];
    };

    # hostName -> static IPv4. Pick addresses outside your router's DHCP pool.
    hosts = mkOption {
      type = types.attrsOf types.str;
      default = {
        caddy = "192.168.1.220";
        jellyfin = "192.168.1.221";
      };
    };

    # Everything Caddy reverse-proxies. Add an entry here when you add a VM/service.
    services = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              subdomain = mkOption {
                type = types.str;
                default = name;
              };
              host = mkOption {
                type = types.str;
                description = "Key in my.homelab.hosts (or a literal IP/hostname).";
              };
              port = mkOption { type = types.port; };
            };
          }
        )
      );
      default = {
        jellyfin = {
          host = "jellyfin";
          port = 8096;
        };
      };
    };
  };
}
