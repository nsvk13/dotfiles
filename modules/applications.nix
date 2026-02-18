{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Terminals
    tabby

    # VPN tools
    wireguard-tools
    amnezia-vpn

    # Development
    vscode

    # Communication
    discord
    telegram-desktop

    # Browsers
    firefox
  ];
}
