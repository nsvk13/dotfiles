# Терминал: Ghostty.
#
# Раньше здесь был kitty — он достался от настройки под driftwm, где дефолтный
# бинд mod+Return открывал именно его. driftwm убрали, kitty остался и по факту
# не использовался (в сессии работал Konsole).
#
# Почему не Tabby, который нравился: его в nixpkgs нет вовсе — пакет `tabby`
# это TabbyML, self-hosted AI-ассистент, другой проект. А сам Tabby написан на
# Electron, отсюда и лаги на Linux. Ghostty даёт то же ощущение — вкладки,
# сплиты, красивые дефолты — но нативно и на GPU.
#
# Konsole остаётся установленным как запасной и интегрированный с Plasma;
# его профиль Nordic настроен в ../desktop/apps.nix.
{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # Звук по завершении команды. Ghostty узнаёт о ней через OSC 133, которые
      # ставит shell integration (включена строкой выше) — без неё не работает.
      #
      # unfocused, а не always: пикает только когда окно не в фокусе. То есть
      # запустил `tofu apply` или долгий playbook, ушёл в браузер — вернёшься по
      # звуку. При always звенело бы на каждый ls, и это выключишь через день.
      notify-on-command-finish = "unfocused";
      # bell — звук, notify — всплывашка Plasma. В дефолте notify выключен.
      notify-on-command-finish-action = "bell,notify";

      # Дефолт bell-features — no-system,no-audio, то есть тишина: Ghostty не
      # звучит, пока звук не включат явно и не дадут файл. Системная тема звуков
      # в Plasma не настроена, поэтому берём файл из пакета напрямую —
      # заодно он попадает в зависимости генерации.
      bell-features = "audio,attention,title";
      bell-audio-path = "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/complete.oga";
      bell-audio-volume = 0.4;

      # Тема встроена в Ghostty (одна из 463), отдельный пакет не нужен.
      # Список — `ghostty +list-themes`, имя подставляется как есть.
      #
      # Kanagawa Wave вместо Nord: фон темнее (#1f1f28 против #2e3440), акценты
      # приглушённее. Остальной риц пока на Nord (../desktop/nordic.nix, zellij
      # в ./cli.nix, VS Code в ./vscode.nix) — терминал теперь из него выбивается.
      theme = "Kanagawa Wave";

      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;

      # Прозрачность + блюр. На KDE Ghostty не размывает сам, а просит об этом
      # KWin через его плагин Blur — он у нас включён в ../desktop/nordic.nix,
      # так что это работает. На других DE background-blur не поддерживается.
      background-opacity = 0.92;
      background-blur = true;

      window-padding-x = 10;
      window-padding-y = 8;

      # Декорации рисует Plasma, чтобы окно вело себя как остальные: Breeze,
      # цветовая схема Nordic, те же кнопки.
      window-decoration = true;
      gtk-tabs-location = "top";

      cursor-style = "bar";
      copy-on-select = "clipboard";

      # Не переспрашивать при закрытии вкладки, где ничего не выполняется.
      confirm-close-surface = false;
    };
  };
}
