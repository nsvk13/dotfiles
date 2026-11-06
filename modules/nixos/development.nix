{ user, ... }:

{
  # `docker compose` and `docker buildx` ship with the docker package itself.
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
    daemon.settings = {
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
    };
  };
  users.users.${user}.extraGroups = [ "docker" ];

  # Prebuilt foreign binaries (VS Code server, LSPs, npm/bun native modules) just work.
  programs.nix-ld.enable = true;
}
