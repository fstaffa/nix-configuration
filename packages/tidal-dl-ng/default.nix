{
  lib,
  python312Packages,
  fetchFromGitHub,
  ffmpeg-full,
}:

python312Packages.buildPythonApplication rec {
  pname = "tidal-dl-ng";
  version = "0.27.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "exislow";
    repo = "tidal-dl-ng";
    rev = "v${version}";
    hash = "sha256-yDVLLAgJztcUthEv228TlntqRdVKVnHEFDiLT+txr8Q=";
  };

  nativeBuildInputs = with python312Packages; [
    poetry-core
  ];

  propagatedBuildInputs = with python312Packages; [
    requests
    mutagen
    dataclasses-json
    pathvalidate
    m3u8
    coloredlogs
    rich
    toml
    typer
    tidalapi
    python-ffmpeg
    pycryptodome
  ];

  # GUI optional dependencies
  passthru.optional-dependencies = {
    gui = with python312Packages; [
      pyside6
      pyqtdarktheme
    ];
  };

  # Runtime dependency
  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ ffmpeg-full ]}"
  ];

  # Tests require TIDAL credentials
  doCheck = false;

  # Patch pyproject.toml to relax typer version constraint
  # tidal-dl-ng specifies typer ^0.16.0 (meaning <0.17.0) but works fine with 0.17.x
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'typer = "^0.16.0"' 'typer = ">=0.16.0"'
  '';

  meta = with lib; {
    description = "TIDAL media downloader with multithreaded capabilities";
    homepage = "https://github.com/exislow/tidal-dl-ng";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    mainProgram = "tidal-dl-ng";
  };
}
