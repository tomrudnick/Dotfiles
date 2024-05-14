{
    description = "My first flake!";

    inputs = {
        #nixpkgs.url = "nixpkgs/nixos-23.11";
        home-manager.url = "github:nix-community/home-manager/master";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    };

    outputs = { self, home-manager, nixpkgs, ... }: 
        let
            lib = nixpkgs.lib;
            system = "x86_64-linux";
            pkgs = nixpkgs.legacyPackages.${system};
        in {
        nixosConfigurations = {
            nixos = lib.nixosSystem {
                inherit system;
                modules = [
                    ./desktop-pc/configuration.nix
                ];
            };
        };

        nixosConfigurations = {           
            nixos-tux-tom = lib.nixosSystem {
                inherit system;
                modules = [
                    ./tuxedo-pulse-15/configuration.nix
                ];
            };
        };
        homeConfigurations = {
          "tom@nixos" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./desktop-pc/home.nix ];
          };
        };
        homeConfigurations = {
          "tom@nixos-tux-tom" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./tuxedo-pulse-15/home.nix ];
          };
        };
    };
}
