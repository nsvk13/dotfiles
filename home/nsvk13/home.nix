{ config, pkgs, ... }:

{
  imports = [
    ./programs/hyprland.nix
    ./programs/waybar.nix
    ./programs/zsh.nix
    ./programs/terminal.nix
    ./programs/git.nix
    ./programs/waybar.nix
  ];

  home.username = "nsvk13";
  home.homeDirectory = "/home/nsvk13";
  home.stateVersion = "24.11";

  # Fonts
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # GTK theme
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        variant = "mocha";
      };
    };
  };

  programs.home-manager.enable = true;
}