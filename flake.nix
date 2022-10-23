{
  description = "stskeygen for cimpress aws";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
        packages.stskeygen =
          let
            mappings = {
              x86_64-linux = { url = "Linux_x86_64"; sha256 = "1p23ngrmd9bn318gr6vw9j6012xd6pdc5ac4lgfr8s9w73svgbcx"; };
              i686-linux = { url = "Linux_i386"; sha256 = "0zwk6hscml8xnrwh1hl6fdkh7pidbgq0lmgdfapv7j0bylhxcsbn"; };
              aarch64-linux = { url = "Linux_arm64"; sha256 = "0wzg3a7w450fk43ppvc6r6d2rzmbwd3r224s29vzyb3i3jcz1388"; };
              x86_64-darwin = { url = "Darwin_x86_64"; sha256 = "0qcf4spqb1zg8zb578y6g6p13mrrdhymwif7f4brr9pjr6qvkbyj"; };
              aarch64-darwin = { url = "Darwin_arm64"; sha256 = "1igqjyw32if4m0383bq3i5dwrxlhn04pj2n2wb79nhnvkwqq9rvi"; };
            };
            urlSystem = mappings.${system}.url;

          in
          with import nixpkgs { system = system; };
          stdenv.mkDerivation rec {
            name = "stskeygen-${version}";

            version = "2.2.10";

            # https://nixos.wiki/wiki/Packaging/Binaries
            src = pkgs.fetchurl {
              url = "https://ce-installation-binaries.s3.us-east-1.amazonaws.com/stskeygen/${version}/stskeygen_${version}_${urlSystem}.tar.gz";
              sha256 = mappings.${system}.sha256;
            };

            sourceRoot = ".";

            installPhase = ''
              install -m755 -D stskeygen $out/bin/stskeygen
            '';

            meta = with lib; {
              homepage = "";
              description = "stskeygen for cimpress aws";
            };
          };
      }
    );
}
