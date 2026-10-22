{ inputs, config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
  username = config.my.username;
in
{
  # TrueNAS VM: Jellyfin, reading media from the NAS "media" SMB share at /mnt/media.
  flake.nixosConfigurations.jellyfin = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.home-manager.nixosModules.home-manager

      nixos.truenas-guest
      nixos.nix-settings
      nixos.base
      nixos.server
      nixos.user
      nixos.zsh
      nixos.nas
      nixos.jellyfin
      nixos.tailscale
      {
        networking.hostName = "jellyfin";
        # Match the value in the /etc/nixos/configuration.nix the installer generated.
        system.stateVersion = "26.05";

        # Only the media share, owned by the jellyfin service user.
        nas = {
          shares = [ "media" ];
          owner = "jellyfin";
          group = "jellyfin";
        };

        # Don't start Jellyfin until the share is reachable (triggers the automount).
        systemd.services.jellyfin.unitConfig.RequiresMountsFor = [ "/mnt/media" ];

        # Hardware transcoding needs a GPU passed through to the VM in TrueNAS. For an Intel iGPU:
        # hardware.graphics = {
        #   enable = true;
        #   extraPackages = with pkgs; [ intel-media-driver vpl-gpu-rt ];
        # };
        # users.users.jellyfin.extraGroups = [ "render" "video" ];

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
