{ pkgs, ... }:

{
  # Plasma 6 on Wayland. The X11 session ("plasmax11") stays installed as a fallback
  # and needs the X server; xserver.enable also loads GPU kernel modules early.
  services.xserver.enable = true;

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    # Plasma is the only session installed now; this also pre-selects it in the
    # greeter if another one is ever added back.
    defaultSession = "plasma";

    # NO autoLogin on purpose. With it enabled SDDM went straight into
    # `defaultSession` on every boot and never drew the greeter, so there was no way
    # to pick a different session — and the one path that should have worked, logging
    # out, raced the autologin session for VT 1 and killed the greeter a second after
    # it started:
    #
    #   Greeter session started successfully
    #   Auth: sddm-helper exited with 5
    #   Greeter stopped. SDDM::Auth::HELPER_TTY_ERROR
    #   Jumping to VT 1
    #
    # which presents as a black screen with no session picker. Leaving autologin off
    # keeps the greeter reachable — it is the only way to pick a different session, or
    # a different user, without editing the config first.
  };
  services.desktopManager.plasma6.enable = true;

  hardware.graphics.enable = true;

  # Electron/Chromium apps (VS Code, Discord, ...) run as native Wayland clients.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    # Адаптер оказывался выключенным после загрузки — в bluedevilglobalrc
    # лежала запись <адрес>_powered=false, и включать приходилось руками.
    powerOnBoot = true;

    # Без этого флага PipeWire 1.6 пишет в лог:
    #   spa.bluez5: Using legacy bluez5 API for A2DP — only SBC will be
    #   supported. Please upgrade bluez5.
    # Experimental открывает новые интерфейсы org.bluez, через которые PipeWire
    # умеет переключать кодеки A2DP. Без него AAC недоступен, даже если
    # наушники его объявляют — G435 объявляет, codec 2 на одном из SEP.
    settings.General.Experimental = true;
  };

  # Bluetooth-наушники подключались в гарнитурном профиле (headset-head-unit,
  # кодек mSBC) — это моно 16 кГц для звонков, звук соответствующий. A2DP при
  # этом существовал на уровне bluez (пять SEP с UUID 0000110b, кодеки SBC и
  # AAC), но PipeWire не создавал для него профиль, и wireplumber писал:
  #   Could not find valid non-headset profile, not switching
  #
  # Руками лечилось явным вызовом ConnectProfile по UUID A2DP Sink; настройки
  # ниже делают это поведением по умолчанию. Проверялось на Logitech G435.
  services.pipewire.wireplumber.extraConfig."51-bluez-prefer-a2dp" = {
    # bluez5.auto-connect — свойство УСТРОЙСТВА, а не монитора, поэтому задаётся
    # правилом, а не в monitor.bluez.properties. Видно по bluez.lua: секция
    # properties уходит в SpaDevice("api.bluez5.enum.dbus", …) — то есть в
    # монитор перечисления (строка 398), а до самого устройства свойства
    # доезжают только через match_rules_update_properties(config.rules, …)
    # (строки 367-370). В libspa-bluez5.so bluez5.auto-connect лежит в
    # контексте api.bluez5.device рядом с bluez5.hw-volume, что это и
    # подтверждает. В monitor.bluez.properties ключ просто игнорируется.
    "monitor.bluez.rules" = [
      {
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions.update-props = {
          # Поднимать A2DP, а не только гарнитурный профиль.
          "bluez5.auto-connect" = [
            "a2dp_sink"
            "hfp_hf"
          ];
        };
      }
    ];

    "monitor.bluez.properties" = {
      # Эти ключи — наоборот, именно monitor-уровня: в libspa-bluez5.so они
      # идут группой в контексте адаптерных quirks.
      "bluez5.roles" = [
        "a2dp_sink"
        "a2dp_source"
        "hfp_hf"
        "hfp_ag"
        "hsp_hs"
        "hsp_ag"
      ];
      # Порядок значим: PipeWire берёт первый, который поддержали наушники.
      # sbc_xq — тот же SBC на повышенном битрейте, слышно заметно лучше.
      "bluez5.codecs" = [
        "aac"
        "sbc_xq"
        "sbc"
      ];
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.hfphsp-backend" = "native";
    };

    # Главное. По дефолту true: wireplumber уводит наушники в гарнитурный
    # профиль, едва какое-нибудь приложение откроет микрофон, и музыка
    # превращается в телефонный звонок. Микрофон здесь отдельный (fifine),
    # так что гарнитурный профиль не нужен вовсе.
    "wireplumber.settings" = {
      "bluetooth.autoswitch-to-headset-profile" = false;
    };
  };

  fonts.packages = with pkgs; [
    inter # UI-шрифт Plasma и GTK; до этого был дефолтный Noto Sans 10
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # Ассеты оформления. Системно, а не в home.packages, чтобы их видел и SDDM.
  #
  # Про nordic: используются только share/color-schemes (Nordic.colors) и
  # share/themes (GTK 2/3/4). Его share/plasma/desktoptheme и
  # share/plasma/look-and-feel содержат лишь metadata.desktop — формат Plasma 5,
  # а Plasma 6 требует metadata.json, поэтому как Plasma style или global theme
  # Nordic не загрузится. Plasma style остаётся нативным breeze-dark: он
  # наследует системную цветовую схему, так что панели всё равно станут
  # нордическими.
  environment.systemPackages = with pkgs; [
    nordic
    papirus-icon-theme
    bibata-cursors

    # KWin-скрипт автоматического тайлинга. Включается и настраивается в
    # home/nsvk13/desktop/nordic.nix через kwinrc; здесь только пакет, чтобы
    # KWin нашёл его в share/kwin/scripts внутри XDG_DATA_DIRS.
    kdePackages.krohnkite
  ];

  programs.firefox.enable = true;
}
