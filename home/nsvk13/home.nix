{ pkgs, lib, inputs, osConfig, ... }:

let
  # driftwm is a trackpad-first compositor — only the laptop (tuf) gets it, not the M7.
  isTuf = osConfig.networking.hostName == "tuf";
in
{
  imports = [
    ./programs/zsh.nix
    ./programs/terminal.nix
    ./programs/git.nix
    ./programs/devops.nix
    inputs.driftwm.homeModules.driftwm
    # Must come with the driftwm module: it declares the one option home-manager's
    # way-displays module expects every compositor to have. See the file for why.
    ./driftwm-compat.nix
  ];

  home.username = "nsvk13";
  home.homeDirectory = "/home/nsvk13";
  # Follows the host: 24.11 on the TUF, whatever the M7 gets installed with.
  home.stateVersion = osConfig.system.stateVersion;

  home.packages =
    (with pkgs; [
      btop
      nvtopPackages.full
    ])
    # Tools driftwm's default keybinds reach for (mod+d launcher, screenshots,
    # brightness / media keys, lock). Without them those binds are silent no-ops.
    ++ lib.optionals isTuf (with pkgs; [
      fuzzel # mod+d app launcher (exec-launcher picks it up)
      grim # screenshots (Print)
      slurp # region select for screenshots (shift+Print)
      wl-clipboard # wl-copy, used by the screenshot binds
      brightnessctl # XF86MonBrightness* keys
      playerctl # XF86Audio* media keys
      swaylock # mod+l screen lock (PAM is wired by the driftwm NixOS module)
    ]);

  # driftwm per-user config. mod+Return (exec-terminal) resolves to kitty automatically.
  # Kept minimal on purpose — driftwm ships sane defaults; extend from its reference:
  # https://github.com/malbiruk/driftwm/blob/main/config.reference.toml
  wayland.windowManager.driftwm = {
    enable = isTuf;
    settings = {
      mod_key = "super";
      focus_follows_mouse = true;
    };
  };

  programs.home-manager.enable = true;
}
