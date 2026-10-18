{ config, ... }:
let
  dots = config.my.dotfilesPath;
in
{
  # System side: compositor + UWSM session. No display manager: like on Arch, you log in
  # on tty1 and ~/.zprofile runs `uwsm start hyprland.desktop`.
  flake.modules.nixos.hyprland = {
    programs.hyprland = {
      enable = true; # also sets up xdg-desktop-portal-hyprland
      withUWSM = true;
    };

    security.polkit.enable = true;
    services.gvfs.enable = true; # trash/mounts in Thunar
    environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Electron/Chromium on Wayland
  };

  # User side: link ~/.config/hypr from the dotfiles repo + everything your Lua config calls.
  flake.modules.homeManager.hyprland =
    { config, pkgs, ... }:
    {
      # Home Manager's wayland.windowManager.hyprland is deliberately NOT enabled:
      # it would generate ~/.config/hypr/hyprland.lua and clash with this link.
      xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink "${dots}/hypr";

      # Replaces /usr/lib/hyprpolkitagent/hyprpolkitagent from autolaunch.lua.
      # Started by graphical-session.target, which UWSM brings up.
      services.hyprpolkitagent.enable = true;

      home.packages = with pkgs; [
        hyprshot # Print binds
        rose-pine-hyprcursor # `hyprctl setcursor rose-pine-hyprcursor 24`
        cliphist # `wl-paste --watch cliphist store`
        wl-clipboard
        brightnessctl
        playerctl
      ];
    };
}
