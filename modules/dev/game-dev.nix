
{
  flake.modules.homeManager.game-dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        unityhub
      ];
    };
}
