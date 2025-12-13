{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/system/boot.nix
    ../../modules/system/networking.nix
    ../../modules/system/locale.nix
    ../../modules/system/users.nix

    ../../modules/system/nvidia.nix
    ../../modules/desktop/kde.nix

    ../../modules/dev/base.nix
    ../../modules/dev/languages.nix
    ../../modules/dev/devops.nix

    ../../modules/virtualization/docker.nix
  ];

  system.stateVersion = "24.05";
}
