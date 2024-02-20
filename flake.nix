{
    description = "My first flake!";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-23.11";
        home-manager.url = "github:nix-community/home-manager/release-23.11";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, home-manager, unstable, ... }: 
        let
            lib = nixpkgs.lib;
            system = "x86_64-linux";
            pkgs = nixpkgs.legacyPackages.${system};
            pkgs-unstable = unstable.legacyPackages.${system};
        in {
        nixosConfigurations = {
            nixos = lib.nixosSystem {
                inherit system;
                modules = [ ./configuration.nix ];
                specialArgs = { inherit pkgs-unstable; };
            };
        };
        homeConfigurations = {
            tom = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [ ./home.nix ];
            };
        };
    };
}