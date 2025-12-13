{
  description = "Rust dev shell (fenix)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    fenix.url = "github:nix-community/fenix";
  };

  outputs = { self, nixpkgs, fenix }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          fenix.packages.${system}.complete.toolchain
          pkgs.pkg-config
          pkgs.openssl
        ];
      };
    };
}