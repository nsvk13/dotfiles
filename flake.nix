{
  description = "nsvk13 NixOS config (ASUS TUF A15, AMD + NVIDIA, Wayland)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/laptop/configuration.nix
      ];
    };
  };
}