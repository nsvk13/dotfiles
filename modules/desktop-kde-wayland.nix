{ config, pkgs, ... }:

{
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.power-profiles-daemon.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}