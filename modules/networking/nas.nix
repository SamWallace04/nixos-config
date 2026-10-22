{ config, ... }:
let
  user = config.my.username;
  nasHost = config.my.homelab.nasAddress;

  # SMB credentials live outside the Nix store. Create this file manually (mode 600):
  #   username=<truenas user>
  #   password=<password>
  credentialsFile = "/etc/nixos/smb-secrets";
in
{
  flake.modules.nixos.nas =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.nas;

      # Mount on first access (and at boot via remote-fs.target) without blocking boot if the NAS is down.
      smbOptions = [
        "credentials=${credentialsFile}"
        "uid=${cfg.owner}"
        "gid=${cfg.group}"
        "file_mode=0664"
        "dir_mode=0775"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "x-systemd.mount-timeout=10"
        "_netdev"
        "noauto"
        "nofail"
      ];
    in
    {
      options.nas = {
        # TrueNAS exposes SMB shares by share name, which defaults to the dataset name.
        # Each share is mounted at /mnt/<share>.
        shares = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "downloads"
            "media"
          ];
        };
        # Local user/group the mounted files appear to belong to.
        owner = lib.mkOption {
          type = lib.types.str;
          default = user;
        };
        group = lib.mkOption {
          type = lib.types.str;
          default = "users";
        };
      };

      config = {
        environment.systemPackages = [ pkgs.cifs-utils ];

        fileSystems = lib.listToAttrs (
          map (
            share:
            lib.nameValuePair "/mnt/${share}" {
              device = "//${nasHost}/${share}";
              fsType = "cifs";
              options = smbOptions;
            }
          ) cfg.shares
        );
      };
    };
}
