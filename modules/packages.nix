{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable     = true;
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    # ── CLI / Utils ─────────────────────────────────────────────────────────
    htop
    btop
    git
    bun
    wget
    iptables
    pciutils
    powertop
    duf
    dust
    claude-code

    # ── GPU ─────────────────────────────────────────────────────────────────
    nvtopPackages.nvidia
    mesa-demos

    # ── Приложения ──────────────────────────────────────────────────────────
    discord
    obsidian
    obs-studio
    vscode
    telegram-desktop
    amnezia-vpn
    ghostty
    tabby-terminal
    slack

    # ── Темы / Иконки ───────────────────────────────────────────────────────
    adwaita-icon-theme
    papirus-icon-theme

    # ── Шрифты ──────────────────────────────────────────────────────────────
    fira-code
    jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
}