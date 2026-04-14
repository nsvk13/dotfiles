{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.xkb = {
    layout  = "ru,us";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  services.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
  };
  services.desktopManager.gnome.enable = true;

  console.keyMap = "us";
  qt.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL          = "1";
    __GL_SYNC_TO_VBLANK     = "0";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}