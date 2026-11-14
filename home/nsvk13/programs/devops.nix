{ pkgs, ... }:

{
  # Per-project toolchains go into flake devShells; direnv loads them on `cd`.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    # Shell basics
    ripgrep
    fd
    bat
    eza
    jq
    yq-go
    httpie

    # Languages used outside of project shells
    nodejs_24
    bun
    python3
    uv

    # Databases
    postgresql

    # Containers & Kubernetes
    kubectl
    kubernetes-helm
    kubectx
    k9s
    stern
    kind
    dive
    lazydocker

    # Сеть и DNS
    dnsutils # dig: без него в системе вообще нечем сверить DNS,
    # а `host` не умеет ни +short на произвольный тип, ни trace
    termshark # TUI поверх tshark: разбор WireGuard-хендшейков и pcap
    # в терминале, без выгрузки дампа в GUI Wireshark.
    # Для ЗАХВАТА нужен dumpcap с setcap — см. programs.wireshark
    # в modules/nixos/development.nix; чтение файлов работает и так

    # Infra & git
    opentofu
    ansible
    sops
    age
    gh
    lazygit
  ];
}
