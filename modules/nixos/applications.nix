{ pkgs, ... }:

{
  # Amnezia VPN выключена в пользу NetBird (modules/nixos/netbird.nix): два
  # VPN одновременно спорят за маршрут по умолчанию. Модуль поднимал ещё и
  # root-демон, без которого клиент всё равно не поднимал туннели, — теперь
  # этот демон в системе не нужен.
  #
  # Вернуть: programs.amnezia-vpn.enable = true; но тогда держите NetBird
  # отключённым, пока пользуетесь Amnezia.

  # Zed убран: стоял здесь с 16f2925, где им разблокировали установку вместо
  # не собиравшегося vscode. Пакет vscode починен в home/nsvk13/programs/
  # vscode.nix, так что запасной редактор больше не нужен.

  # spotify-spotx вместо spotify: тот же клиент, но с вырезанной рекламой
  # (overlay SpotX-Nix подключён в modules/nixos/base.nix). Дополнительные
  # аргументы SpotX-Bash — через override, например:
  #   (spotify-spotx.override { spotxArgs = [ "--hide" ]; })
  environment.systemPackages = with pkgs; [
    wireguard-tools
    claude-code
    discord
    telegram-desktop
    slack
    spotify-spotx
  ];
}
