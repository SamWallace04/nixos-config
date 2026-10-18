{
  # System side: Thunar itself (plus its D-Bus service), and dconf so the
  # Home Manager color-scheme setting below can be written.
  flake.modules.nixos.thunar = {
    programs.thunar.enable = true;
    programs.dconf.enable = true;
  };

  # User side: dark GTK theme. Thunar is GTK3, so this is what it renders with.
  flake.modules.homeManager.thunar =
    { pkgs, ... }:
    {
      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };
        gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
        gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
      };

      # Picked up by libadwaita/portal-aware apps too.
      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
}
