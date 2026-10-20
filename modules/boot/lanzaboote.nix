{ inputs, ... }:
{
  # Secure Boot via Lanzaboote. Keys must exist first: `sudo sbctl create-keys`.
  # See https://nix-community.github.io/lanzaboote/getting-started/prepare-your-system.html
  flake.modules.nixos.lanzaboote =
    { pkgs, lib, ... }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      environment.systemPackages = [ pkgs.sbctl ];

      # Lanzaboote replaces the systemd-boot module.
      boot.loader.systemd-boot.enable = lib.mkForce false;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
}
