{
  flake.modules.nixos.gaming = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    programs.steam.enable = true;   # also turns on 32-bit graphics
  };

  flake.modules.homeManager.gaming =
    { pkgs, lib, ... }:
    let
      dwprotonVersion = "10.0-26";
      dwproton = pkgs.fetchzip {
        url = "https://dawn.wine/dawn-winery/dwproton/releases/download/dwproton-${dwprotonVersion}/dwproton-${dwprotonVersion}-x86_64.tar.xz";
        hash = "sha256-TkwhJCHPS0PdDIEL5GrxJPR09uO9U2DR8l9KWFLIF2g=";
      };
    in
    {
      home.packages = with pkgs; [
        lutris
        wineWow64Packages.staging
        winetricks
      ];
      # Lutris (and Steam) pick up Proton builds from this folder.
      xdg.dataFile."Steam/compatibilitytools.d/dwproton-${dwprotonVersion}".source = dwproton;
    };
}
