{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # System modules
    ../../modules/system/boot.nix
    ../../modules/system/networking.nix
    ../../modules/system/locale.nix
    ../../modules/system/users.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/sound.nix

    # Hardware
    ../../modules/system/nvidia.nix
    
    # Desktop
    ../../modules/desktop/kde.nix

    # Development
    ../../modules/dev/base.nix
    ../../modules/dev/languages.nix
    ../../modules/dev/devops.nix

    # Virtualization
    ../../modules/virtualization/docker.nix
  ];

  system.stateVersion = "24.05";
}
