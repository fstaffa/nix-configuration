{ pkgs, system }:

let
  inherit (pkgs) lib callPackage;

  # Read all subdirectories in the packages directory
  packageDirs = builtins.attrNames (
    lib.filterAttrs (name: type: type == "directory" && name != "default.nix") (
      builtins.readDir ./.
    )
  );

  # Build a package from a directory if it has a default.nix and is supported on this system
  buildPackage =
    name:
    let
      pkg = callPackage ./${name} { };
      # Check if package has platform restrictions
      isPlatformSupported =
        if pkg ? meta && pkg.meta ? platforms then
          builtins.elem system pkg.meta.platforms
        else
          true; # If no platform restriction, assume it works everywhere
    in
    if isPlatformSupported then pkg else null;

  # Create an attribute set of all packages
  packages = lib.listToAttrs (
    map (name: {
      name = name;
      value = buildPackage name;
    }) packageDirs
  );
in
packages
