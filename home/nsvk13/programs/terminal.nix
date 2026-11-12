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
{ ... }:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # Тема Nord встроена в Ghostty (одна из 463), отдельный пакет не нужен.
      theme = "Nord";

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
