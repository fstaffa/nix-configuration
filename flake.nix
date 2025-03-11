{
  description = "Home manager configuration";
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    personal-packages.url = "github:fstaffa/nix-packages";
    personal-packages.inputs.nixpkgs.follows = "nixpkgs";

    emacsNext-src.url = "github:emacs-mirror/emacs";
    emacsNext-src.flake = false;

    chemacs2 = {
      url = "github:plexus/chemacs2";
      flake = false;
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, home-manager, darwin, nixpkgs, emacs-overlay
    , personal-packages, chemacs2, emacsNext-src, ... }@inputs:
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
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in { default = pkgs.callPackage ./shell.nix { }; });

      # This instantiates nixpkgs for each system listed above
      # Allowing you to add overlays and configure it (e.g. allowUnfree)
      # Our configurations will use these instances
      # Your flake will also let you access your package set through nix build, shell, run, etc.
      legacyPackages = forAllSystems (system:
        import inputs.nixpkgs {
          inherit system;
          # This adds our overlays to pkgs
          overlays = [
            (final: prev: {
              burpsuite = prev.burpsuite.override (old: { proEdition = true; });
              streamcontroller =
                let rev = "79efabee57e464da2c4f9657175819bbb4cb6856";
                in prev.streamcontroller.overrideAttrs (old: {
                  inherit rev;
                  src = prev.fetchFromGitHub {
                    owner = "StreamController";
                    repo = "StreamController";
                    inherit rev;
                    hash =
                      "sha256-49VYCjfkr2TnpKSrjLP3ZUcUZPKZxeZxe68F+AnDLng=";
                  };
                });
            })
          ];

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
            emacs31-pgtk =
              emacs-overlay.packages.x86_64-linux.emacs-pgtk.overrideAttrs (_: {
                name = "emacs31";
                version = "31.0-${inputs.emacsNext-src.shortRev}";
                src = inputs.emacsNext-src;
              });
          }; # Pass flake inputs to our config
          # > Our main home-manager configuration file <
          modules = [ ./home-manager/hosts/iguana ];

        };
        "fstaffa@raptor" = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages.aarch64-darwin;
          extraSpecialArgs = {
            inherit inputs;
            personal-packages = personal-packages.packages.aarch64-darwin;
            emacs31-pgtk =
              emacs-overlay.packages.aarch64-darwin.emacs-pgtk.overrideAttrs
              (_: {
                name = "emacs31";
                version = "31.0-${inputs.emacsNext-src.shortRev}";
                src = inputs.emacsNext-src;
              });
          }; # Pass flake inputs to our config
          # > Our main home-manager configuration file <
          modules = [ ./home-manager/hosts/macbook-work ];
        };
      };

      nixosConfigurations = {
        base-server-iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./nixos-configurations/hosts/base-server-iso ];

        };
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
        "raptor" = darwin.lib.darwinSystem {
          modules = [ ./darwin-configurations/hosts/macbook-work ];
          system = "aarch64-darwin";
        };
      };

      formatter = forAllSystems
        (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
