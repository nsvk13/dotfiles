{ pkgs, ... }:

{
  home.username = "nsvk13";
  home.homeDirectory = "/home/nsvk13";
  home.stateVersion = "25.11";

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Inter";
      size = 11;
      package = pkgs.inter;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "Papirus-Dark";
      font-name = "Inter 11";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
      document-font-name = "Inter 11";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };

    "org/gnome/shell" = {
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "blur-my-shell@aunetx"
        "appindicatorsupport@rgcjonas.gmail.com"
        "just-perfection-desktop@just-perfection"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "openweather-extension@penguin-teal.github.io"
        "tophat@fflewddur.github.io"
        "mediacontrols@cliffniff.github.com"
      ];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      extend-height = false;
      dock-fixed = false;
      autohide = true;
      intellihide = true;
      transparency-mode = "FIXED";
      background-opacity = 0.2;
      intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      sigma = 30;
    };

    "org/gnome/shell/extensions/just-perfection" = {
      animation = 1;
      dash = true;
      activities-button = true;
    };
  };

  home.packages = with pkgs; [
    inter
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.appindicator
    gnomeExtensions.just-perfection
    gnomeExtensions.user-themes
    gnomeExtensions.openweather-refined
    gnomeExtensions.tophat
    gnomeExtensions.media-controls
  ];
}
