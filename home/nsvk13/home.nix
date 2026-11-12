{ pkgs, osConfig, ... }:

{
  imports = [
    ./programs/zsh.nix
    ./programs/terminal.nix
    ./programs/git.nix
    ./programs/devops.nix
  ];

  home.username = "nsvk13";
  home.homeDirectory = "/home/nsvk13";
  # Follows the host: 24.11 on the TUF, whatever the M7 gets installed with.
  home.stateVersion = osConfig.system.stateVersion;

  home.packages = with pkgs; [
    btop
    nvtopPackages.full
  ];

  programs.home-manager.enable = true;
}
