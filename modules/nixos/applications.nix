{ pkgs, ... }:

{
  # The client needs its root daemon; the bare package alone cannot bring tunnels up.
  programs.amnezia-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    wireguard-tools
    zed-editor
    claude-code
    discord
    telegram-desktop
  ];
}
