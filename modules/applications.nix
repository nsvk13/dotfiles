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
}
