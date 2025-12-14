{ pkgs, ... }:

{
  home.username = "nsvk13";
  home.homeDirectory = "/home/nsvk13";

  imports = [
    ./shell.nix
    ./git.nix
    ./editors.nix
  ];

  home.stateVersion = "24.05";
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
