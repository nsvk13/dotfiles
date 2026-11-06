{ ... }:

{
  programs.kitty = {
    enable = true;
    themeFile = "tokyo_night_night";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      background_opacity = "0.95";
    };
  };
}
