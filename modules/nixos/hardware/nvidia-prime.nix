# NVIDIA dGPU in a hybrid laptop: the iGPU renders the desktop, the dGPU wakes up
# only for what you launch with `nvidia-offload <app>` (and for the HDMI port it drives).
# Bus IDs are set per host.
{ ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Recommended by NVIDIA for Turing and newer; required for kernel suspend notifiers.
    open = true;
    branch = "production";

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
    };

    # Save VRAM across suspend + power the dGPU off (RTD3) when nothing uses it.
    powerManagement = {
      enable = true;
      finegrained = true;
    };
  };
}
