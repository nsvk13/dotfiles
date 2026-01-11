{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git neovim vim
    docker docker-compose
    kubectl k9s
    nodejs_20 bun python3
    postgresql
    curl wget httpie
    jq yq ripgrep fd bat eza
  ];

  virtualisation.docker.enable = true;
}