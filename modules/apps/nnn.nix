{
  flake.modules.homeManager.nnn =
    { config, ... }:
    {
      programs.nnn.enable = true;

      # Stable path for .zshrc to source the cd-on-quit function `n` from. Home Manager's
      # programs.nnn.quitcd only hooks into programs.zsh, which zsh.nix leaves disabled.
      home.file.".zsh/nnn-quitcd.zsh".source =
        "${config.programs.nnn.finalPackage}/share/quitcd/quitcd.bash_sh_zsh";
    };
}
