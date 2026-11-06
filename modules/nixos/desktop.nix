{ pkgs, user, ... }:

{
  # Plasma 6 on Wayland. The X11 session ("plasmax11") stays installed as a fallback
  # and needs the X server; xserver.enable also loads GPU kernel modules early.
  services.xserver.enable = true;

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "plasma";
    autoLogin = {
      enable = true;
      inherit user;
    };
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
