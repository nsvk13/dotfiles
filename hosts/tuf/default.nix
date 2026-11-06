# ASUS TUF Gaming A15 — AMD Ryzen (iGPU drives the internal panel) + RTX 4060 Laptop.
{ inputs, lib, ... }:

{
  imports = [
    ../../modules/nixos/hardware/amd.nix
    ../../modules/nixos/hardware/nvidia-prime.nix
    ../../modules/nixos/hardware/asus.nix
    inputs.driftwm.nixosModules.driftwm
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  assertions = [
    {
      assertion = builtins.pathExists ./hardware-configuration.nix;
      message = "hosts/tuf/hardware-configuration.nix is missing: run ./scripts/bootstrap.sh tuf on the laptop.";
    }
  ];

  # Dual boot with Windows, same as before.
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  # `lspci -D | grep -E 'VGA|3D'` prints HEX, these are DECIMAL.
  hardware.nvidia.prime = {
    amdgpuBusId = "PCI:5@0:0:0";
    nvidiaBusId = "PCI:1@0:0:0";
  };

  # Windows keeps the RTC in local time; match it so the clock doesn't jump when you
  # boot back and forth (dual boot via GRUB os-prober).
  time.hardwareClockInLocalTime = true;

  # driftwm — trackpad-first infinite-canvas Wayland compositor. The NixOS module
  # registers a "driftwm" session in SDDM; the iGPU that drives the panel renders it at
  # full refresh. Per-user config is in home-manager. Plasma stays the default session.
  programs.driftwm.enable = true;

  # Installed with 24.11 — never bump this, it is not "the NixOS version".
  system.stateVersion = "24.11";
}
