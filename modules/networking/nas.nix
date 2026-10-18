{ config, ... }:
let
  user = config.my.username;
  nasHost = "192.168.1.214";

  # SMB credentials live outside the Nix store. Create this file manually (mode 600):
  #   username=<truenas user>
  #   password=<password>
  credentialsFile = "/etc/nixos/smb-secrets";
in
{
  flake.modules.nixos.nas =
    { pkgs, ... }:
    let
      # Mount on first access (and at boot via remote-fs.target) without blocking boot if the NAS is down.
      smbOptions = [
        "credentials=${credentialsFile}"
        "uid=${user}"
        "gid=users"
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
      environment.systemPackages = [ pkgs.cifs-utils ];

      # TrueNAS exposes SMB shares by share name, which defaults to the dataset name.
      fileSystems."/mnt/downloads" = {
        device = "//${nasHost}/downloads";
        fsType = "cifs";
        options = smbOptions;
      };

      fileSystems."/mnt/media" = {
        device = "//${nasHost}/media";
        fsType = "cifs";
        options = smbOptions;
      };
    };
}
