{
  description = "nsvk13's NixOS configuration";

  inputs = {
    # Stable release: security fixes without surprise breakage.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Escape hatch for individual packages: pkgs.unstable.<name>
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Декларативная конфигурация KDE Plasma 6.
    # Ветки release-26.05 у plasma-manager нет, только trunk и plasma-5. Берём
    # trunk с follows на оба наших input'а, чтобы он не тянул третий nixpkgs.
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      plasma-manager,
      ...
    }@inputs:
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
                sharedModules = [ plasma-manager.homeModules.plasma-manager ];
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
