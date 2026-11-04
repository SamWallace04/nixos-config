{ config, ... }:
let
  user = config.my.username;
in
{
  flake.modules.nixos.docker = {
    # The docker package ships the compose and buildx plugins (`docker compose ...`).
    virtualisation.docker = {
      enable = true;
      # Optional: weekly `docker system prune` (stopped containers, unused networks, dangling images).
      # autoPrune.enable = true;
    };

    # Lets you run docker without sudo. Note: membership is effectively root access.
    users.users.${user}.extraGroups = [ "docker" ];
  };
}
