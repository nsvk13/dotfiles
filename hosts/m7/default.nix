# Ninkear M7
{ lib, ... }:

{
  imports = [
    ../../modules/nixos/hardware/amd.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  assertions = [
    {
      assertion = builtins.pathExists ./hardware-configuration.nix;
      message = "hosts/m7/hardware-configuration.nix is missing: run ./scripts/bootstrap.sh m7 on the machine.";
    }
  ];

  # The graphical installer sets up systemd-boot on UEFI; keep it.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  # Set to the release the machine was first installed with, then never touch it.
  system.stateVersion = "26.05";
}
