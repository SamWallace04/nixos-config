{ inputs, config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
  username = config.my.username;
in
{
  flake.nixosConfigurations.sam-pc = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ./_hardware.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.self.modules.nixos.fonts

      nixos.nix-settings
      nixos.base
      nixos.lanzaboote
      nixos.user
      nixos.zsh
      nixos.hyprland
      nixos.neovim
      nixos.noctalia
      nixos.audio
      nixos.fonts
      nixos.amd-gpu
      nixos.general
      nixos.thunar
      nixos.gaming
      nixos.tailscale
      nixos.nas
      {
        networking.hostName = "sam-pc";
        # Match the value in the /etc/nixos/configuration.nix the installer generated.
        system.stateVersion = "26.05";

        hardware.bluetooth.enable = true;

        # 2TB CT2000BX500SSD1 (sdc1)
        fileSystems."/media/data" = {
          device = "/dev/disk/by-uuid/e39cfb1f-c108-48c2-acc2-b4dc0ad33ee9";
          fsType = "ext4";
          options = [
            "nodev"
            "nosuid"
            "nofail"
          ];
        };

        # 2TB Samsung SSD 990 PRO (nvme0n1p1)
        fileSystems."/media/data2" = {
          device = "/dev/disk/by-uuid/f2201012-ae6b-4e57-acdc-6d1fdc8b1b90";
          fsType = "ext4";
          options = [
            "nodev"
            "nosuid"
            "nofail"
          ];
        };

        home-manager.users.${username} = {
          imports = with homeManager; [
            user
            zsh
            terminal
            hyprland
            noctalia
            launchers
            neovim
            git
            go
            rust
            dotnet
            cli-tools
            gaming
            browser
            general
            thunar
            tailscale
            ai
          ];
          home.stateVersion = "26.05";
        };
      }
    ];
  };
}
