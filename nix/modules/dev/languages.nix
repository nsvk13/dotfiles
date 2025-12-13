{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nodejs_20
    bun
    go
    python312
    gcc
    clang
    cmake
    gdb
    rustc
    cargo
  ];
}