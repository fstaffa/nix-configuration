{
  description = "stskeygen for cimpress aws";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
        defaultPackage =
          let
            mappings = {
              x86_64-linux = { url = "Linux_x86_64"; sha256 = "sha256-hbOcBepNRxJ6LgMtB6SPN66gUiurZs9F6WjLi7VkIGs="; };
              i686-linux = { url = "Linux_x86_i686"; sha256 = ""; };
              aarch64-linux = { url = "Linux_arm64"; sha256 = ""; };
              x86_64-darwin = { url = "Darwin_x86_64"; sha256 = ""; };
              aarch64-darwin = { url = "Darwin_arm64"; sha256 = ""; };
            };
            urlSystem = mappings.${system}.url;

          in
          with import nixpkgs { system = system; };
          stdenv.mkDerivation rec {
            name = "stskeygen-${version}";

            version = "2.2.9";

            # https://nixos.wiki/wiki/Packaging/Binaries
            src = pkgs.fetchurl {
              url = "https://ce-installation-binaries.s3.us-east-1.amazonaws.com/stskeygen/2.2.9/stskeygen_2.2.9_" + urlSystem + ".tar.gz";
              sha256 = mappings.${system}.sha256;
            };

            sourceRoot = ".";

            installPhase = ''
              install -m755 -D stskeygen $out/bin/stskeygen
            '';

            meta = with lib; {
              homepage = "https://support.cimpress.cloud/hc/en-us/articles/360049195674-stskeygen";
              description = "stskeygen for cimpress aws";
            };
          };


      }
    );
}
