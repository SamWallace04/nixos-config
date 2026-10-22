{
  flake.modules.nixos.gaming = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    programs.steam.enable = true;   # also turns on 32-bit graphics
  };

  flake.modules.homeManager.gaming =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        lutris
        wineWow64Packages.staging
        winetricks
      ];
    };
}
