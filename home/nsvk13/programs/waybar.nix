{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      position = "top";
      height = 28;

      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" ];

      clock.format = "{:%H:%M}";
    };
  };
}