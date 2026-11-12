{ pkgs, ... }:

{
  # Amnezia VPN выключена в пользу NetBird (modules/nixos/netbird.nix): два
  # VPN одновременно спорят за маршрут по умолчанию. Модуль поднимал ещё и
  # root-демон, без которого клиент всё равно не поднимал туннели, — теперь
  # этот демон в системе не нужен.
  #
  # Вернуть: programs.amnezia-vpn.enable = true; но тогда держите NetBird
  # отключённым, пока пользуетесь Amnezia.

  environment.systemPackages = with pkgs; [
    wireguard-tools
    zed-editor
    claude-code
    discord
    telegram-desktop
    slack
  ];
}
