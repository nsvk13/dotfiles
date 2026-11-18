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
  #
  # opencode берётся из unstable: в nixos-26.05 заморожен 1.15.10, в
  # unstable — 2.2.5. Для CLI-агента разница принципиальная, релизы у него
  # идут недельным темпом, а список провайдеров и моделей живёт в самом
  # бинарнике. Переехать на stable, когда он там догонит мажор.
  environment.systemPackages = with pkgs; [
    wireguard-tools
    claude-code
    unstable.opencode
    discord
    # Два клиента Telegram намеренно. ayugram-desktop — форк с Ghost mode
    # (не отмечать прочитанным, не слать «печатает»), расширенной
    # кастомизацией и локальным хранением удалённых сообщений.
    #
    # Версия одна и та же в 26.05 и unstable (7.2.9), так что оверлей не нужен.
    #
    # telegram-desktop оставлен: у форков Telegram регулярно случаются
    # блокировки API-ключа, и в такой день нужен рабочий запасной клиент.
    # Данные у них раздельные — ~/.local/share/AyuGram против
    # ~/.local/share/TelegramDesktop, сессии друг другу не мешают.
    ayugram-desktop
    telegram-desktop
    slack
    spotify-spotx
    obsidian
    burpsuite
  ];
}
