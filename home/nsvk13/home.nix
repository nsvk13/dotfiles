{ config, pkgs, ... }:

{
  imports = [
    ./programs/zsh.nix
    ./programs/terminal.nix
    ./programs/git.nix
  ];

  home.username = "nsvk13";
  home.homeDirectory = "/home/nsvk13";
  home.stateVersion = "24.11";

  # Fonts
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # GTK theme
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk;
    };
  };

  programs.home-manager.enable = true;
}
