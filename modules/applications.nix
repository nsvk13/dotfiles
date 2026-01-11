{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Terminals
    tabby
    
    # VPN tools
    wireguard-tools
    
    # Development
    vscode
    
    # Communication
    discord
    telegram-desktop
    
    # Browsers
    firefox
  ];

  # Для Discord/Electron с Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}