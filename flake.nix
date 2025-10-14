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

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Add streamcontroller repository
    streamcontroller.url = "github:StreamController/StreamController/be88bad807d66c3595f19f778bf92904951919e8";
    streamcontroller.flake = false;

    # Disko for declarative disk partitioning
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      home-manager,
      darwin,
      nixpkgs,
      emacs-overlay,
      personal-packages,
      emacsNext-src,
      streamcontroller,
      disko,
      ...
    }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in
    rec {
      # Devshell for bootstrapping
      # Accessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          default = pkgs.callPackage ./shell.nix { };
        }
      );

      # Custom packages
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        import ./packages { inherit pkgs system; }
      );

      # This instantiates nixpkgs for each system listed above
      # Allowing you to add overlays and configure it (e.g. allowUnfree)
      # Our configurations will use these instances
      # Your flake will also let you access your package set through nix build, shell, run, etc.
      legacyPackages = forAllSystems (
        system:
        import inputs.nixpkgs {
          inherit system;
          # This adds our overlays to pkgs
          overlays = [
            (final: prev: {
              burpsuite = prev.burpsuite.override (old: {
                proEdition = true;
              });
              # streamcontroller = let rev = streamcontroller.rev;
              # in prev.streamcontroller.overrideAttrs (old: {
              #   inherit rev;
              #   src = streamcontroller;
              # });
            })
            # Add custom packages overlay
            (final: prev: packages.${system})
          ];

          # NOTE: Using `nixpkgs.config` in your NixOS config won't work
          # Instead, you should set nixpkgs configs here
          # (https://nixos.org/manual/nixpkgs/stable/#idm140737322551056)
          config.allowUnfree = true;
        }
      );

      homeConfigurations = {
        "mathematician314@iguana" = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs;
            personal-packages = personal-packages.packages.x86_64-linux;
            emacs31-pgtk = emacs-overlay.packages.x86_64-linux.emacs-pgtk.overrideAttrs (_: {
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
            emacs31-pgtk = emacs-overlay.packages.aarch64-darwin.emacs-pgtk.overrideAttrs (_: {
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
        downloader = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./nixos-configurations/hosts/downloader
          ];
        };
      };

      darwinConfigurations = {
        "raptor" = darwin.lib.darwinSystem {
          modules = [ ./darwin-configurations/hosts/macbook-work ];
          system = "aarch64-darwin";
        };
      };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
