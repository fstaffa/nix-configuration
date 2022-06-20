{
  description = "stskeygen for cimpress aws";

  outputs = { self, nixpkgs }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };
      stdenv.mkDerivation rec {
        name = "stskeygen-${version}";

        version = "2.2.9";

        # https://nixos.wiki/wiki/Packaging/Binaries
        src = pkgs.fetchurl {
          url = "https://ce-installation-binaries.s3.us-east-1.amazonaws.com/stskeygen/2.2.9/stskeygen_2.2.9_Linux_x86_64.tar.gz";
          sha256 = "sha256-hbOcBepNRxJ6LgMtB6SPN66gUiurZs9F6WjLi7VkIGs=";
        };

        sourceRoot = ".";

        installPhase = ''
          install -m755 -D stskeygen $out/bin/stskeygen
        '';

        meta = with lib; {
          homepage = "https://support.cimpress.cloud/hc/en-us/articles/360049195674-stskeygen";
          description = "stskeygen for cimpress aws";
          platforms = platforms.linux;
        };
      };


  };
}
