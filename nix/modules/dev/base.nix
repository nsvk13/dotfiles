{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    unzip
    htop
    neovim
    tmux
  ];
}