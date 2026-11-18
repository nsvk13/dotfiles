# Nordic / Minimal — оформление Plasma 6.
#
# Что здесь ЕСТЬ: цветовая схема, Plasma style, иконки, курсор, шрифты, GTK,
# обои, splash, KWin-эффекты, рабочие столы, хоткеи.
# Панели — в ./panels.nix, Konsole и Dolphin — в ./apps.nix.
#
# Чего здесь НЕТ, и почему:
#   - lookAndFeel  — plasma-apply-lookandfeel перезаписывает
#                    ~/.config/kdedefaults/*, а вместе с windowDecorations ещё
#                    и даёт eval-warning: L&F-темы переопределяют эти настройки.
#                    Отдельные ключи ниже дают тот же вид, не трогая kdedefaults
#                    (проверено на живой системе: его mtime не изменился).
#   - desktop      — виджеты и иконки на рабочем столе; требует контейнментов
#   - window-rules — при непустом списке plasma-manager удаляет kwinrulesrc
#                    даже при overrideConfig = false (files.nix:88)
#   - Kvantum      — дублирует Breeze и добавляет точку отказа
#   - kitty        — у него осознанная тема tokyo_night_night, не трогаем
#
# ВЫКЛЮЧИТЬ: enable = false, затем rebuild + logout/login.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  enable = true;

  # Панели живут в ./panels.nix под отдельным флагом: это единственная часть
  # конфигурации с необратимым побочным эффектом при первом применении —
  # подробности и порядок откатa описаны в шапке того файла.
  # Бэкап снят в ~/kde-backup-2026-11-11-1030.
  enablePanels = true;

  # Берёт ли Home Manager на себя GTK-мост.
  #
  # true  — ~/.config/gtk-{3,4}.0/settings.ini и ~/.gtkrc-2.0 становятся
  #         симлинками в /nix/store. Это ЕДИНСТВЕННОЕ место в Phase 1, где мы
  #         забираем файлы, которые сейчас пишет сам Plasma (kde-gtk-config).
  #         Прежние версии сохранятся как *.hm-backup — backupFileExtension
  #         уже настроен в flake.nix. Побочный эффект: kde-gtk-config больше не
  #         сможет их перезаписывать при смене схемы.
  #         gtk-3.0/gtk.css с его `@import 'colors.css'` HM не трогает, но это
  #         безвредно: все 84 определения в colors.css имеют суффикс _breeze, а
  #         Nordic-darker ни на одно из них не ссылается — мёртвый CSS.
  #         gtk-4.0/gtk.css HM заменяет (GTK4 игнорирует gtk-theme-name и
  #         читает тему только из пользовательского CSS).
  # false — GTK остаётся полностью на стороне Plasma, Qt-часть темы работает
  #         как обычно.
  manageGtk = true;

  # Обои генерируются из той же палитры, что и тема, а не берутся стоковыми.
  # Радиальный градиент nord2 (#434C5E) в центре → nord0 (#2E3440) к краям:
  # мягкое пятно света, без «фотообоев», которые выбиваются из минимализма.
  #
  # Шум и лёгкое размытие — против полосатости (banding): чистый градиент на
  # 8 битах даёт заметные ступени на больших площадях.
  #
  # -depth 8 обязателен: без него magick отдаёт 16-битный PNG на 9.2 МБ,
  # и он целиком попадает в замыкание системы. С ним — 2.0 МБ, как у
  # стоковых обоев KDE.
  nordWallpaper =
    pkgs.runCommand "nord-wallpaper"
      {
        nativeBuildInputs = [ pkgs.imagemagick ];
      }
      ''
        mkdir -p $out
        magick -size 1920x1080 \
          radial-gradient:'#434C5E'-'#2E3440' \
          -attenuate 0.18 +noise Gaussian \
          -blur 0x0.6 \
          -depth 8 \
          -define png:compression-level=9 \
          -define png:compression-filter=5 \
          $out/wallpaper.png
      '';
in

{
  # imports вычисляются до config, поэтому их тоже надо гасить по `enable` —
  # иначе apps.nix и panels.nix применились бы при enable = false и флаг
  # перестал бы быть полноценным выключателем.
  imports = lib.optionals enable ([ ./apps.nix ] ++ lib.optional enablePanels ./panels.nix);

  config = lib.mkIf enable (lib.mkMerge [
    {
      programs.plasma = {
        enable = true;

        # НЕ включать без отдельного решения: при true plasma-manager удаляет 38
        # файлов конфигурации на КАЖДОЙ генерации, включая kglobalshortcutsrc,
        # kxkbrc (раскладка us,ru из base.nix) и dolphinrc.
        # При false он не удаляет ничего (единственное исключение — kwinrulesrc,
        # и только если задан window-rules, чего мы не делаем) и правит
        # существующие файлы по отдельным ключам, а не заменяет их целиком.
        overrideConfig = false;

        workspace = {
          # Nordic — из pkgs.nordic. Это единственное, что делает вид «нордическим».
          # Из того же пакета НЕЛЬЗЯ брать Plasma style и global theme: его
          # share/plasma/{desktoptheme,look-and-feel}/Nordic* имеют только
          # metadata.desktop (формат Plasma 5), а Plasma 6 требует metadata.json.
          colorScheme = "Nordic";

          # Нативный Plasma style. Breeze наследует системную цветовую схему,
          # поэтому панели и виджеты окрасятся в Nordic автоматически.
          theme = "breeze-dark";
          widgetStyle = "Breeze";

          iconTheme = "Papirus-Dark";

          cursor = {
            theme = "Bibata-Modern-Ice";
            size = 24;
          };

          # Нативный Breeze: следует цветовой схеме, в отличие от SVG-тем Aurorae.
          windowDecorations = {
            library = "org.kde.breeze";
            theme = "Breeze";
          };

          # Минимализм: без заставки при входе. Движок plasma-manager подставит
          # сам ("None" → engine none), отдельно задавать его нельзя — ассерт
          # требует theme при заданном engine, но не наоборот.
          splashScreen.theme = "None";

          # Обои собираются сборкой, см. nordWallpaper выше. Ровно 1920x1080 под
          # этот монитор, масштабирование не нужно. Раньше здесь был стоковый
          # IceCold из KDE — он нормальный, но узнаваемо «из комплекта».
          wallpaper = "${nordWallpaper}/wallpaper.png";
        };

        # Осознанный пин. До этого ни один ключ шрифта не был задан вообще, и
        # Plasma отдавала дефолтный Noto Sans 10.
        fonts = {
          general = {
            family = "Inter";
            pointSize = 10;
          };
          small = {
            family = "Inter";
            pointSize = 8;
          };
          toolbar = {
            family = "Inter";
            pointSize = 10;
          };
          menu = {
            family = "Inter";
            pointSize = 10;
          };
          windowTitle = {
            family = "Inter";
            pointSize = 10;
          };
          fixedWidth = {
            family = "JetBrainsMono Nerd Font";
            pointSize = 10;
          };
        };

        # Никакого сна, затемнения и автоблокировки. Машина живёт на внешнем
        # мониторе в discrete-режиме MUX, внутренняя панель убита kernel-
        # параметром — это де-факто десктоп, который складывается. Засыпать ему
        # незачем, а автоблокировка только мешает.
        #
        # "never" — валидное значение, не выдумка: тип опции idleTimeout это
        # nullOr (either (enum ["never"]) (ints.between 30 600000)).
        powerdevil =
          let
            noSleep = {
              autoSuspend.action = "nothing";
              # idleTimeoutWhenLocked здесь НЕ задаётся сознательно: модуль
              # роняет сборку ассертом, если его указать вместе с
              # idleTimeout = "never". Логично — настраивать нечего, экран
              # не гаснет ни в каком состоянии.
              turnOffDisplay.idleTimeout = "never";
              dimDisplay.enable = false;
              # Дублирует logind из hosts/tuf/default.nix, где лид уже
              # игнорируется — но пусть и Plasma знает, чтобы не спорила.
              whenLaptopLidClosed = "doNothing";
              powerButtonAction = "showLogoutScreen";
            };
          in
          {
            AC = noSleep;
            # На батарее тоже. Внезапный сон посреди работы раздражает сильнее,
            # чем разряд, о котором всё равно предупредит индикатор.
            battery = noSleep;
            lowBattery = noSleep;
          };

        kscreenlocker = {
          autoLock = false;
          lockOnResume = false;
          lockOnStartup = false;
        };

        # ПЕРЕНОС, НЕ НОВЫЕ БИНДЫ. Это единственные рукотворные хоткеи на этой
        # машине: сверка всех 269 строк kglobalshortcutsrc поле-в-поле с
        # дефолтами дала ровно эти два отклонения. Объявляем, чтобы они жили в
        # Nix, а не только на диске. Значения совпадают с текущими, так что
        # запись — no-op по результату.
        shortcuts.plasmashell = {
          "next activity" = "Meta+A";
          "previous activity" = "Meta+Shift+A";
        };

        kwin = {
          # Рабочих столов было 1, при этом на панели висел pager с единственной
          # ячейкой. Заводим осознанно — тогда и pager, и slide-анимация, и
          # штатные Meta+Ctrl+стрелки обретают смысл.
          virtualDesktops = {
            number = 4;
            rows = 1;
          };

          effects = {
            # blur и contrast в Plasma 6.6 включены ПО ДЕФОЛТУ — здесь мы их
            # фиксируем и оставляем дефолтную силу (15/5). Единственный выход
            # висит на RTX 4060 в discrete-режиме, dGPU не уходит в сон, так
            # что поднимать силу выше дефолта смысла нет.
            blur = {
              enable = true;
              strength = 15;
              noiseStrength = 5;
            };

            # Прозрачность. По дефолту эффект translucency делает полупрозрачными
            # перемещаемые окна и диалоги, но НЕ неактивные окна — именно это нам
            # и нужно: полупрозрачность неактивных окон на Wayland даёт артефакты
            # с Electron-клиентами, а у нас NIXOS_OZONE_WL=1.
            translucency.enable = true;

            # Анимации окон выключены.
            #
            # Было: windowOpenClose = "scale", minimization = "squash". Squash
            # схлопывает окно в полоску к панели, и на 165 Гц это читается как
            # рывок, а не как плавность. Плюс оба эффекта добавляют задержку
            # между кликом и реакцией — окно уже «сворачивается», а работать с
            # ним ещё нельзя.
            #
            # "off" — валидное значение обоих enum, проверено по kwin.nix:
            # windowOpenClose принимает fade|glide|scale|off,
            # minimization — squash|magiclamp|off.
            windowOpenClose.animation = "off";
            minimization.animation = "off";

            # Переключение столов оставлено: оно происходит по явной команде,
            # а не на каждый клик, и помогает понять, куда уехал экран.
            desktopSwitching.animation = "slide";
          };

          # false: развёрнутые окна сохраняют титулбар.
          #
          # При true он пропадал, и закрыть окно мышью было нечем — под это
          # в панель ставился виджет application-title-bar с чужими кнопками.
          # Убрано и то, и другое: кнопки должны быть на окне, а не в панели.
          borderlessMaximizedWindows = false;

          # Барьеры на краях мешают при одном широком мониторе.
          edgeBarrier = 0;
          cornerBarrier = false;
        };

        configFile."kwinrc" = {
          "Plugins".contrastEnabled = true;

          # ТАЙЛИНГ ВЫКЛЮЧЕН. Был krohnkite с зазорами 8 px — выглядел
          # аккуратно на скриншоте, но на деле мешал: окна разъезжаются сами,
          # перетащить и положить куда хочется нельзя, каждое новое окно
          # перекраивает раскладку остальных.
          #
          # false, а не удаление ключа: если просто убрать строку, в kwinrc
          # останется krohnkiteEnabled=true с прошлой генерации — plasma-manager
          # при overrideConfig = false ничего не удаляет, только дописывает.
          "Plugins".krohnkiteEnabled = false;
        };
      };
    }

    (lib.mkIf manageGtk {
      gtk = {
        enable = true;
        theme = {
          name = "Nordic-darker";
          package = pkgs.nordic;
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
        font = {
          name = "Inter";
          size = 10;
        };
        # HM 26.05 сменил дефолт gtk4.theme с config.gtk.theme на null, но при
        # home.stateVersion < 26.05 (у нас 24.11) всё ещё действует legacy-дефолт
        # и HM предупреждает об этом. Задаём явно: Nordic-darker содержит
        # gtk-4.0, так что GTK4-приложения должны получить ту же тему.
        gtk4.theme = config.gtk.theme;

        gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
        gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
      };

      # Курсор для GTK и XWayland. ~/.icons не существует, так что ничего не
      # перезаписывается. Qt-сторона курсора идёт через workspace.cursor выше.
      home.pointerCursor = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };

      # Корень проблемы: модуль gtkconfig в kded (gtkconfig.so) переписывает
      # GTK-файлы при каждом применении темы. ~/.gtkrc-2.0 он не правит на месте,
      # а заменяет обычным файлом поверх симлинка HM. На следующей активации HM
      # пытается сделать бэкап, упирается в уже существующий *.hm-backup и
      # падает с "would be clobbered" — switch завершается с ошибкой.
      #
      # Отключаем модуль: тему GTK теперь целиком задаёт HM (см. gtk выше), а
      # colors.css, который генерировал gtkconfig, и так мёртв — Nordic-darker
      # не ссылается ни на одну из его переменных *_breeze.
      # Привязано к manageGtk: при manageGtk = false модуль снова включится и
      # GTK вернётся под управление Plasma.
      programs.plasma.configFile."kded6rc"."Module-gtkconfig".autoload = false;

      # Подстраховка на случай, если GTK-файлы всё же окажутся обычными файлами
      # (другой писатель, ручная правка, остаток от прошлой генерации): HM
      # перезапишет их без бэкапа вместо того, чтобы падать. Оригиналы уже
      # сохранены в ~/kde-backup-2026-11-11-1030/gtk/.
      # mkForce обязателен: сам gtk-модуль HM задаёт force = false явно
      # (modules/misc/gtk/gtk2.nix), и без повышения приоритета получается
      # конфликт определений на этапе eval.
      home.file.${config.gtk.gtk2.configLocation}.force = lib.mkForce true;
      xdg.configFile = {
        "gtk-3.0/settings.ini".force = lib.mkForce true;
        "gtk-4.0/settings.ini".force = lib.mkForce true;
        "gtk-4.0/gtk.css".force = lib.mkForce true;
      };
    })
  ]);
}
