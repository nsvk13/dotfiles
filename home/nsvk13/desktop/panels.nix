# Плавающая верхняя панель + минималистичный нижний док.
#
# ⚠️ ДЕСТРУКТИВНО ПРИ ПЕРВОМ ПРИМЕНЕНИИ. Модуль panels в plasma-manager
# безусловно делает rm ~/.config/plasma-org.kde.plasma.desktop-appletsrc
# (modules/panels.nix:247), и это происходит независимо от overrideConfig.
# Вместе с панелью исчезают контейнменты рабочего стола, wallpaperplugin и
# конфиги всех виджетов.
#
# Что было заменено: ОДНА стоковая нижняя плавающая панель 46 px с порядком
# kickoff, pager, icontasks, marginsseparator, systemtray, digitalclock,
# showdesktop — то есть дефолт Plasma 6 Breeze, ничего рукотворного.
#
# Порядок выполнения важен и он корректен: скрипты запускаются как
# {priority}_{name}.sh, у панелей priority = 2, у обоев priority = 3. Значит
# панели пересоздают appletsrc ДО того, как в него пишутся обои.
#
# Модуль panels не аддитивный — он описывает полный список панелей. Нельзя
# описать одну и оставить другую нетронутой: либо все панели в Nix, либо ни одна.
{ ... }:

{
  programs.plasma.panels = [
    # Верхняя панель — статус. Плавающая, полупрозрачная, всегда видима.
    {
      location = "top";
      height = 36;
      floating = true;
      hiding = "none";
      opacity = "translucent";

      widgets = [
        # Colorizer должен идти ПЕРВЫМ: он не рисует себя, а перекрашивает
        # панель и остальные виджеты. Пакет plasma-panel-colorizer
        # plasma-manager ставит сам.
        #
        # Что он делает: убирает штатную однородную плашку панели и подкладывает
        # под каждый виджет отдельный скруглённый прямоугольник. Именно это
        # отличает «кастомную сборку» от «просто тёмной темы».
        #
        # Тонкую доводку удобнее делать в его собственном GUI (правый клик →
        # настроить), а итог потом переносить сюда. Здесь — осмысленная база.
        {
          plasmaPanelColorizer = {
            widgetBackground = {
              enable = true;
              colorMode.mode = "static";
              colors = {
                source = "custom";
                # nord1 — на тон светлее фона рабочего стола (nord0 #2E3440),
                # поэтому «таблетки» читаются, но не спорят с обоями.
                customColor = "#3B4252";
              };
              shape = {
                radius = 10;
                opacity = 0.85;
              };
            };

            # Штатная плашка панели убирается полностью: фон теперь дают
            # «таблетки» под виджетами, а между ними видно обои с blur.
            panelBackground.originalBackground.opacity = 0.0;
          };
        }

        "org.kde.plasma.kickoff"
        # Имеет смысл только потому, что в nordic.nix заведено 4 рабочих стола.
        "org.kde.plasma.pager"

        # Заголовок активного окна и кнопки управления прямо в панели. Это
        # закрывает дыру от borderlessMaximizedWindows = true в nordic.nix:
        # у развёрнутых окон нет титулбара, и закрыть их мышью было нечем.
        # Пакет application-title-bar plasma-manager ставит сам.
        {
          applicationTitleBar = {
            behavior.activeTaskSource = "activeTask";
            layout = {
              # Кнопки перечисляются по одной — группы "windowControlButtons"
              # в этом enum нет, она описывает только их оформление ниже.
              elements = [
                "windowIcon"
                "windowTitle"
                "windowMinimizeButton"
                "windowMaximizeButton"
                "windowCloseButton"
              ];
              horizontalAlignment = "left";
              verticalAlignment = "center";
              showDisabledElements = "deactivated";
            };
            windowTitle = {
              source = "appName";
              hideEmptyTitle = true;
              font = {
                bold = false;
                fit = "fixedSize";
                size = 10;
              };
            };
          };
        }

        "org.kde.plasma.panelspacer"
        {
          digitalClock = {
            time.format = "24h";
            calendar.firstDayOfWeek = "monday";
          };
        }
        "org.kde.plasma.panelspacer"

        # Что играет. Данные берутся по MPRIS, поэтому работает с чем угодно:
        # Spotify, YouTube в Firefox, Elisa. Пакет ставится автоматически.
        {
          plasmusicToolbar = {
            playbackSource = "auto";
            panelIcon = {
              albumCover = {
                useAsIcon = true;
                radius = 6;
              };
              icon = "view-media-track";
            };
            musicControls.showPlaybackControls = true;
            songText = {
              displayInSeparateLines = false;
              maximumWidth = 320;
              scrolling = {
                behavior = "scrollOnHover";
                speed = 3;
              };
            };
          };
        }

        {
          systemTray.items = {
            # Минимализм: в баре только то, что реально нужно смотреть глазами.
            shown = [
              "org.kde.plasma.networkmanagement"
              "org.kde.plasma.volume"
              "org.kde.plasma.battery"
              # Индикатор раскладки: us,ru из base.nix переключается Alt+Shift.
              "org.kde.plasma.keyboardlayout"
              "org.kde.plasma.notifications"
            ];
            # Остальное из стокового набора — в попап, не удалено.
            hidden = [
              "org.kde.plasma.clipboard"
              "org.kde.plasma.bluetooth"
              "org.kde.plasma.brightness"
              "org.kde.kscreen"
              "org.kde.plasma.cameraindicator"
              "org.kde.plasma.devicenotifier"
              "org.kde.plasma.mediacontroller"
              "org.kde.plasma.manage-inputmethod"
              "org.kde.plasma.keyboardindicator"
              "org.kde.plasma.weather"
            ];
          };
        }
      ];
    }

    # Нижний док на нативной панели Plasma: по центру, по размеру содержимого,
    # уходит под окна когда они подходят вплотную.
    {
      location = "bottom";
      height = 52;
      floating = true;
      alignment = "center";
      lengthMode = "fit";
      hiding = "dodgewindows";
      opacity = "translucent";

      widgets = [
        {
          iconTasks = {
            iconsOnly = true;
            launchers = [
              "applications:firefox.desktop"
              # Ghostty приходит из home-manager, его .desktop лежит в
              # /etc/profiles/per-user/nsvk13/share/applications — этот путь
              # есть в XDG_DATA_DIRS, так что имя разрешается.
              "applications:com.mitchellh.ghostty.desktop"
              "applications:org.kde.dolphin.desktop"
              "applications:dev.zed.Zed.desktop"
              "applications:org.telegram.desktop.desktop"
            ];
          };
        }
      ];
    }
  ];
}
