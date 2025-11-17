{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  cacert,
  glib,
  glib-networking,
  gst_all_1,
  webkitgtk_4_1,
}:

let
  pname = "bambu-studio-appimage";
  
  versions = lib.importJSON ./versions.json;
  info = versions.${stdenv.hostPlatform.system};
  
  version = info.version;
  ubuntu_version = info.ubuntu_version;

  src = fetchurl {
    url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/Bambu_Studio_ubuntu-${ubuntu_version}.AppImage";
    hash = info.hash;
  };
in
appimageTools.wrapType2 {
  name = "BambuStudio";
  inherit pname version src;

  profile = ''
    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
    export GIO_MODULE_DIR="${glib-networking}/lib/gio/modules/"
  '';

  extraPkgs = pkgs: [
    cacert
    glib
    glib-networking
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    webkitgtk_4_1
  ];

  meta = with lib; {
    description = "PC Software for BambuLab's 3D printers";
    homepage = "https://github.com/bambulab/BambuStudio";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    mainProgram = "bambu-studio-appimage";
  };
}
