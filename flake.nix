{
  description = "Home manager configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    personal-packages.url = "github:fstaffa/nix-packages";

    chemacs2 = {
      url = "github:plexus/chemacs2";
      flake = false;
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, home-manager, darwin, nixpkgs, flake-utils, emacs-overlay
    , personal-packages, chemacs2, ... }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in rec {
      # Devshell for bootstrapping
      # Accessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix { };
      });

      # This instantiates nixpkgs for each system listed above
      # Allowing you to add overlays and configure it (e.g. allowUnfree)
      # Our configurations will use these instances
      # Your flake will also let you access your package set through nix build, shell, run, etc.
      legacyPackages = forAllSystems (system:
        import inputs.nixpkgs {
          inherit system;
          # This adds our overlays to pkgs
          overlays = [ emacs-overlay.overlay ];

          # NOTE: Using `nixpkgs.config` in your NixOS config won't work
          # Instead, you should set nixpkgs configs here
          # (https://nixos.org/manual/nixpkgs/stable/#idm140737322551056)
          config.allowUnfree = true;
        });

      homeConfigurations = {
        "mathematician314@iguana" = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs;
            personal-packages = personal-packages.packages.x86_64-linux;
          }; # Pass flake inputs to our config
          # > Our main home-manager configuration file <
          modules = [ ./home-manager/hosts/iguana ];

        };
        "mathematician314@iguana-manjaro" =
          home-manager.lib.homeManagerConfiguration {
            pkgs = legacyPackages.x86_64-linux;
            extraSpecialArgs = {
              inherit inputs;
              personal-packages = personal-packages.packages.x86_64-linux;
            }; # Pass flake inputs to our config
            # > Our main home-manager configuration file <
            modules = [ ./home-manager/hosts/iguana-manjaro ];

          };
        "fstaffa@work" = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages.aarch64-darwin;
          extraSpecialArgs = {
            inherit inputs;
            personal-packages = personal-packages.packages.aarch64-darwin;
          }; # Pass flake inputs to our config
          # > Our main home-manager configuration file <
          modules = [ ./home-manager/hosts/macbook-work ];
        };
      };

      nixosConfigurations = {
        vm-test = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./nixos-configurations/hosts/vm-test ];
        };
        iguana = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./nixos-configurations/hosts/iguana ];
        };
      };

      darwinConfigurations = {
        "macbook-work" = darwin.lib.darwinSystem {
          modules = [ ./darwin-configurations/hosts/macbook-work ];
          system = "aarch64-darwin";
        };
      };

      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
