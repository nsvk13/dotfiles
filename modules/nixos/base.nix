{
  inputs,
  pkgs,
  user,
  hostName,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    })
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
      extra-substituters = [ "https://nix-community.cachix.org" ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    # A rebuild must never make the desktop stutter.
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
  };

  # nh = nicer nixos-rebuild + garbage collection (replaces nix.gc).
  programs.nh = {
    enable = true;
    flake = "/home/${user}/.dotfiles";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  boot.tmp.cleanOnBoot = true;

  networking = {
    inherit hostName;
    networkmanager.enable = true;
  };
  # Nothing on a desktop needs to wait for network at boot.
  systemd.services.NetworkManager-wait-online.enable = false;

  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  # Compressed swap in RAM + kill runaway user processes before the system freezes.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
  systemd.oomd.enableUserSlices = true;

  services.journald.extraConfig = "SystemMaxUse=1G";

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };
  console.useXkbConfig = true;

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    pciutils
    usbutils
    lshw
  ];
}
