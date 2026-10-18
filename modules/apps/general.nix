{
  flake.modules.nixos.general = {
    programs.appimage = {
      enable = true;   
      binfmt = true;
    };
  };
  flake.modules.homeManager.general =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        peazip
        discord
        proton-vpn
        sublime4
        qalculate-qt
      ];
    };
}
