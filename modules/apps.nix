{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    amnezia-vpn

    telegram-desktop
    discord

    vscode
    zed-editor

    tabby

    obsidian

    obs-studio

    tor-browser
  ];
}