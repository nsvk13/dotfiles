{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";

  networking.networkmanager.enable = true;

  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
    networkmanager-wireguard
  ];

  # Звук (PipeWire) + Bluetooth
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.openssh.enable = true;

  networking.firewall.enable = true;

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    git curl wget
    vim nano
    jq ripgrep fd
    unzip zip
    btop
    pciutils usbutils
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };
}