{ ... }:

{
  networking.hostName = "workmachine";
  networking.networkmanager.enable = true;
  
  # Firewall settings
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
}
