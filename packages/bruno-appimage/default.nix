{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
}:

let
  pname = "bruno-appimage";
  versions = lib.importJSON ./versions.json;
  platformData = versions.${stdenv.hostPlatform.system};
  version = platformData.version;

  src = fetchurl {
    url = "https://github.com/usebruno/bruno/releases/download/v${version}/bruno_${version}_x86_64_linux.AppImage";
    hash = platformData.hash;
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/bruno.desktop $out/share/applications/bruno.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/bruno.png $out/share/pixmaps/bruno.png

    substituteInPlace $out/share/applications/bruno.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
  '';

  meta = with lib; {
    description = "Opensource IDE for exploring and testing APIs (Postman/Insomnia alternative)";
    homepage = "https://www.usebruno.com";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    mainProgram = "bruno-appimage";
  };
}
