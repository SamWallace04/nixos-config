{
  flake.modules.homeManager.remmina =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        remmina
      ];
    };
}
