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
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  programs.firefox.enable = true;
}
