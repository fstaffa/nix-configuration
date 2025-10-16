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

    mkdir -p $out/share/agent-os
    cp -r . $out/share/agent-os/

    # Create wrapper scripts for the main scripts
    mkdir -p $out/bin
    for script in scripts/*.sh; do
      scriptName=$(basename "$script" .sh)
      makeWrapper $out/share/agent-os/scripts/$(basename "$script") $out/bin/agent-os-$scriptName \
        --prefix PATH : ${lib.makeBinPath buildInputs}
    done

    # Create a convenience symlink
    ln -s $out/share/agent-os $out/share/agent-os-data

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
