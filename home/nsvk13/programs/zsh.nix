{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "eza -la";
      rebuild = "sudo nixos-rebuild switch --flake ~/.dotfiles#laptop";
      update = "cd ~/.dotfiles && nix flake update && rebuild";
    };
  };

  programs.starship.enable = true;
}
