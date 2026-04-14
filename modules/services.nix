{ pkgs, ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  services.logind = {
    lidSwitch = "ignore";
    settings.Login = {
      HandleSuspendKey   = "ignore";
      HandleHibernateKey = "ignore";
      IdleAction         = "ignore";
      IdleActionSec      = "0";
    };
  };

  services.printing.enable = true;
  services.fstrim = {
    enable   = true;
    interval = "weekly";
  };
  services.thermald.enable = true;
  services.earlyoom = {
    enable            = true;
    freeMemThreshold  = 5;
    freeSwapThreshold = 10;
  };

  virtualisation.docker = {
    enable       = true;
    enableOnBoot = true;
  };

  systemd.services.amnezia-vpn = {
    description = "Amnezia VPN Daemon";
    after    = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type      = "simple";
      User      = "root";
      Group     = "root";
      ExecStart = "${pkgs.amnezia-vpn}/bin/AmneziaVPN-service";
      Restart   = "on-failure";
      RestartSec = 5;
      AmbientCapabilities   = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
      DeviceAllow = "/dev/net/tun";
    };
  };
}