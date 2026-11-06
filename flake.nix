{
  description = "nsvk13's NixOS configuration";

  inputs = {
    # Stable release: security fixes without surprise breakage.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Escape hatch for individual packages: pkgs.unstable.<name>
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # driftwm — trackpad-first infinite-canvas Wayland compositor (laptop only).
    # Deliberately NOT following our nixpkgs: it builds against its own pinned
    # nixos-unstable (Rust edition 2024 + fresh deps), which is what upstream tests —
    # forcing it onto 26.05 risks the build on the machine we can't test from here.
    driftwm.url = "github:malbiruk/driftwm";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      user = "nsvk13";

      # Host name == flake attribute == networking.hostName,
      # so `nh os switch` / `nixos-rebuild --flake .` pick the right one automatically.
      mkHost =
        hostName:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs user hostName; };
          modules = [
            ./modules/nixos
            ./hosts/${hostName}

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-backup";
                extraSpecialArgs = { inherit inputs user; };
                users.${user} = import ./home/${user}/home.nix;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        tuf = mkHost "tuf"; # ASUS TUF Gaming A15, Ryzen + RTX 4060
        m7 = mkHost "m7"; # Ninkear M7
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    };
}
