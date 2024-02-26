{
    description = "My first flake!";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-23.11";
        home-manager.url = "github:nix-community/home-manager/release-23.11";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, home-manager, nixpkgs-unstable, ... }: 
        let
            lib = nixpkgs.lib;
            system = "x86_64-linux";
            pkgs = nixpkgs.legacyPackages.${system};
            unstableOverlay = final: prev: {
                unstable = import nixpkgs-unstable {
                    system = "x86_64-linux";
                    config.allowUnfree = true;
                    overlays = [
                      (self: super: {
                        mailspring = super.mailspring.overrideAttrs (oldAttrs: {
                          postInstall = ''
                            wrapProgram $out/bin/mailspring --add-flags "--password-store=gnome-libsecret" #otherwise passwords can't be stored
                          '';
                        });
                      })
                    ];
                };
            };
        in {
        nixosConfigurations = {
            nixos = lib.nixosSystem {
                inherit system;
                modules = [
                    ({
                        nixpkgs = {
                            overlays = [ unstableOverlay ];
                        };
                    })
                    ./configuration.nix 
                ];
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
