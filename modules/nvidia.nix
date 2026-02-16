{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
  };
}
