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

      # Keyboard layout is the compositor's job on Wayland: driftwm reads this, NOT
      # services.xserver.xkb (that one only reaches Plasma / X). Same us,ru +
      # alt+shift as the rest of the system, kept in sync with modules/nixos/base.nix.
      # grp:alt_shift_toggle is an XKB-level option, so the switch works without
      # binding driftwm's own `switch-layout` action — which is unbound by default.
      input.keyboard = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle";
      };

      # The internal panel is 144 Hz, but EDID's "preferred" mode is only 60 Hz when
      # the dGPU drives it (amdgpu reported 10 modes and preferred 144; nvidia reports
      # 2 and prefers 60), so driftwm came up at 60. "max" takes the highest
      # resolution and then the highest refresh at it.
      #
      # Both connector names are listed on purpose: the panel is eDP-2 in discrete
      # MUX mode (card2, nvidia) and eDP-1 in Optimus mode (card1, amdgpu). An entry
      # for an absent output is simply unused, so this survives flipping muxDiscrete
      # in hosts/tuf/default.nix either way.
      # Background. "tile" repeats the image across the canvas and pans with it, so
      # the infinite canvas stays legible as you move; mirror_tile reflects it in 2x2
      # blocks so a non-seamless photo tiles without visible seams. Picked over
      # "wallpaper" (one image pinned to the viewport, like a normal desktop) because
      # the source is 736x413 and would be visibly soft stretched to 1920x1080 —
      # switch the type if you get a higher-resolution image.
      background = {
        type = "tile";
        path = "/home/nsvk13/Изображения/wallpaper.jpg";
        mirror_tile = true;
      };

      outputs = [
        {
          name = "eDP-1";
          mode = "max";
        }
        {
          name = "eDP-2";
          mode = "max";
        }
      ];
    };
  };

  programs.home-manager.enable = true;
}
