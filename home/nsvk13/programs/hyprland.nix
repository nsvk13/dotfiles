{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,1";
      
      exec-once = [
        "waybar"
        "dunst"
      ];

      "$mod" = "SUPER";

      bind = [
        "$mod, Return, exec, kitty"
        "$mod, Q, killactive"
        "$mod, D, exec, rofi -show drun"
        "$mod, F, fullscreen"
        
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(89b4faee)";
      };

      decoration = {
        rounding = 10;
        blur.enabled = true;
      };

      animations = {
        enabled = true;
        animation = [
          "windows, 1, 5, default"
          "fade, 1, 5, default"
        ];
      };
    };
  };
}