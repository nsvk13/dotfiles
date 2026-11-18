# Консистентное оформление приложений Plasma.
#
# kitty здесь сознательно НЕ трогается: у него осознанно выбранная тема
# tokyo_night_night в home/nsvk13/programs/terminal.nix, и это основной терминал.
# Konsole ниже настраивается на случай, когда он всё-таки открывается (он
# приходит из стандартного набора Plasma), а не как замена kitty.
{ ... }:

{
  # Профилей у Konsole не было вообще (~/.local/share/konsole был пуст), так
  # что здесь ничего не перезаписывается — профиль создаётся с нуля.
  # Схема Nordic.colorscheme приходит из системного пакета nordic через
  # XDG_DATA_DIRS (/run/current-system/sw/share/konsole/Nordic.colorscheme),
  # копировать её в репозиторий не нужно.
  programs.konsole = {
    enable = true;
    defaultProfile = "Nordic";
    profiles.Nordic = {
      name = "Nordic";
      colorScheme = "Nordic";
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 10;
      };
    };
  };

  # Klipper живёт внутри plasmashell и владеет буферами обмена во всей сессии.
  # В X11/Wayland их два: CLIPBOARD (ctrl+c) и PRIMARY (просто выделение мышью).
  # В дефолте Klipper держит их раздельно, поэтому "выделил в браузере" и
  # "скопировал в браузере" дают разное, а вставка зависит от того, чем жмёшь.
  # Здесь они сливаются в один, чтобы поведение совпадало с ghostty
  # (copy-on-select = clipboard в ../programs/terminal.nix).
  programs.plasma.configFile."klipperrc".General = {
    # Выделение и буфер обмена — одно и то же содержимое в обе стороны.
    SyncClipboards = true;
    # Без этого выделение мышью в Klipper не попадает вообще, и Sync нечего
    # синхронизировать: выделил — а в CLIPBOARD по-прежнему прошлое.
    IgnoreSelection = false;
  };

  programs.plasma.configFile."dolphinrc" = {
    # ПЕРЕНОС, НЕ НОВАЯ НАСТРОЙКА: скрытое меню — одна из пяти вещей, которые
    # были настроены руками. Объявляем, чтобы она жила в Nix, а не только на
    # диске. Значение совпадает с тем, что уже лежит в ~/.config/dolphinrc.
    "MainWindow".MenuBar = "Disabled";
    "KFileDialog Settings"."Places Icons Static Size" = 22;

    General = {
      ShowFullPath = true;
      RememberOpenedTabs = false;
    };
    "DetailsMode".PreviewsShown = true;
  };
}
