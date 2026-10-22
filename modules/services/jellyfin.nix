{
  flake.modules.nixos.jellyfin =
    { pkgs, ... }:
    {
      services.jellyfin = {
        enable = true;
        # 8096 (HTTP) for Caddy and direct LAN clients, plus 1900/7359 UDP for client discovery.
        openFirewall = true;
      };

      environment.systemPackages = with pkgs; [
        jellyfin
        jellyfin-web
        jellyfin-ffmpeg
      ];
    };
}
