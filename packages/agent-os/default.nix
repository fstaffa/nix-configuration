{ lib
, stdenvNoCC
, fetchFromGitHub
, makeWrapper
, bash
, coreutils
, curl
, git
, gnugrep
, gnused
, jq
}:

stdenvNoCC.mkDerivation rec {
  pname = "agent-os";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "buildermethods";
    repo = "agent-os";
    rev = "v${version}";
    hash = "sha256-/5n/fpM0YKuAM4491IplQGf1hmxE63xnZlNld2/wBTk=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    bash
    coreutils
    curl
    git
    gnugrep
    gnused
    jq
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Create the artifacts folder and copy all files from git repo
    mkdir -p $out/share/agent-os
    cp -r . $out/share/agent-os/

    # Patch all shell scripts to reference the Nix store path instead of ~/agent-os
    find $out/share/agent-os/scripts -name "*.sh" -type f -exec sed -i \
      "s|BASE_DIR=\"\$HOME/agent-os\"|BASE_DIR=\"$out/share/agent-os\"|g" {} \;

    # Patch hardcoded references to ~/agent-os in messages and error handling
    find $out/share/agent-os/scripts -name "*.sh" -type f -exec sed -i \
      "s|~/agent-os|$out/share/agent-os|g" {} \;

    # Create wrapper scripts for the main scripts
    mkdir -p $out/bin
    for script in scripts/*.sh; do
      scriptName=$(basename "$script" .sh)
      makeWrapper $out/share/agent-os/scripts/$(basename "$script") $out/bin/agent-os-$scriptName \
        --prefix PATH : ${lib.makeBinPath buildInputs}
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Transforms AI coding agents from confused interns into productive developers";
    homepage = "https://buildermethods.com/agent-os";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
