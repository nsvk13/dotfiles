# ASUS ROG / TUF platform integration.
# Canon: https://asus-linux.org/ and the newer https://opengamingcollective.github.io/
# asusctl/ — the asusd daemon (asusctl) and the ROG Control Center GUI. Imported only by
# the ASUS laptop host (tuf).
{ config, pkgs, ... }:

{
  # ASUS laptops get their hardware fixes (asus-wmi, amdgpu, sensors) in recent kernels;
  # upstream recommends 6.19+. Take the latest over the 26.05 default.
  # CAVEAT: with the proprietary NVIDIA driver a brand-new kernel can outpace the driver
  # and fail to build. If `nixos-install` dies on the nvidia module, drop this line (it
  # falls back to the default kernel) and rebuild.

  # asusctl + asusd: keyboard backlight / aura, custom fan curves, platform & power
  # profiles, battery charge limit, panel overdrive. Installs the `asusctl` CLI and the
  # `rog-control-center` GUI and wires up dbus / udev.
  #
  # NB: `services.asusd.enableUserService` was REMOVED in nixpkgs 26.05 (the asusd user
  # service is no longer required), so we don't set it — the asus-linux.org NixOS guide
  # still shows it and is out of date. Likewise the supergfxd `pciutils` PATH workaround
  # from that guide is already baked into the 26.05 module.
  services.asusd.enable = true;

  # asusctl 6.x (26.05 ships 6.3.7) drives the kernel platform_profile and CPU EPP
  # itself — asusd IS the profile daemon. So do NOT run power-profiles-daemon or TLP
  # alongside: upstream warns they fight asusd over platform_profile / EPP. Switch
  # profiles with `asusctl profile <...>` or ROG Control Center (autostarted below).
  #
  # If you want KDE's tray power slider (which needs PPD) back, the alternative is to
  # keep power-profiles-daemon enabled AND tell asusd to stand down, by writing
  # change_platform_profile_on_ac / change_platform_profile_on_battery /
  # platform_profile_linked_epp = false into services.asusd.asusdConfig (/etc/asusd/
  # asusd.ron). We take the simpler path and let asusd own profiles.

  # ROG Control Center, autostarted in the graphical session: the ASUS tray plus the
  # desktop notifications on profile / charge changes. Bound to graphical-session so it
  # comes up under both Plasma and driftwm. Set "close to tray" in its settings once and
  # it stops popping the window on login.
  systemd.user.services.rog-control-center = {
    description = "ROG Control Center (ASUS tray + notifications)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${config.services.asusd.package}/bin/rog-control-center";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
