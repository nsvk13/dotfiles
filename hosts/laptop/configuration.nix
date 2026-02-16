{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nvidia.nix
    ../../modules/development.nix
    ../../modules/applications.nix
  ];

  # Bootloader
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };
    efi.canTouchEfiVariables = true;
  };

  # Networking
  networking = {
    hostName = "nixos-laptop";
    networkmanager.enable = true;
  };

  # Display Manager + Desktop Environments (X11 only)
  services.xserver.enable = true;

  services.displayManager.gdm = {
    enable = true;
    wayland = false;
  };

  services.desktopManager = {
    plasma6.enable = true;
    gnome.enable = true;
  };

  # Time & Locale
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";

  # User
  users.users.nsvk13 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "video" ];
    shell = pkgs.zsh;
  };

  # Programs
  programs = {
    zsh.enable = true;
    amnezia-vpn.enable = true;
  };

  # PipeWire (если вдруг не в модулях)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
