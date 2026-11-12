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

  hardware.bluetooth.enable = true;

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
