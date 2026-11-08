let
  # Outside the Linux ephemeral range (32768-60999) and the 6881-6889 block some trackers reject.
  port = 62881;
in
{
  # System side: let peers reach the torrenting port. TCP for peers, UDP for uTP and DHT.
  flake.modules.nixos.qbittorrent = {
    networking.firewall.allowedTCPPorts = [ port ];
    networking.firewall.allowedUDPPorts = [ port ];
  };

  # User side: qBittorrent rewrites its own config at runtime, so the port is set at launch
  # rather than through a Home Manager managed file. This overrides the port set in the GUI.
  flake.modules.homeManager.qbittorrent =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.symlinkJoin {
          name = "qbittorrent";
          paths = [ pkgs.qbittorrent ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/qbittorrent --set QBT_TORRENTING_PORT ${toString port}
          '';
        })
      ];
    };
}
