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

    # Infra & git
    opentofu
    ansible
    sops
    age
    gh
    lazygit
  ];
}
