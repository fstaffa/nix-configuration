{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.agent-os;

  # Default config with ability to override
  defaultConfig = {
    version = "2.0.4";
    base_install = true;
    multi_agent_mode = true;
    multi_agent_tool = "claude-code";
    single_agent_mode = false;
    single_agent_tool = "generic";
    default_profile = "default";
  };

  configYaml = pkgs.writeText "config.yml" (
    lib.generators.toYAML { } (defaultConfig // cfg.extraConfig)
  );

in
{
  options.programs.agent-os = {
    enable = mkEnableOption "Agent OS";

    package = mkOption {
      type = types.package;
      default = pkgs.agent-os;
      description = "The agent-os package to use";
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = { };
      description = "Additional configuration to merge into config.yml";
      example = literalExpression ''
        {
          multi_agent_mode = false;
          single_agent_mode = true;
        }
      '';
    };

    profiles = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            standards = mkOption {
              type = types.attrsOf types.str;
              default = { };
              description = "Standards files for this profile (name -> content)";
            };
            product = mkOption {
              type = types.attrsOf types.str;
              default = { };
              description = "Product files for this profile (name -> content)";
            };
            specs = mkOption {
              type = types.attrsOf types.str;
              default = { };
              description = "Specs files for this profile (name -> content)";
            };
          };
        }
      );
      default = {
        # Default profile merges with package's built-in profile
        default = {
          standards = {
            "testing/personal.md" = ''
              # Personal Testing Standards

              ## Data-Driven Tests

              If you write tests with the same body but different input and output, prefer writing data-driven tests instead of duplicating test code.

              Data-driven tests (also known as parameterized tests or table-driven tests) improve maintainability by:
              - Reducing code duplication
              - Making it easier to add new test cases
              - Improving test readability
              - Centralizing test logic in one place

              Example:
              Instead of writing multiple similar tests, use a table-driven approach where you define test cases as data structures and iterate over them.
            '';
          };
          product = { };
          specs = { };
        };
      };
      description = "Profiles to create in ~/agent-os/profiles/";
      example = literalExpression ''
        {
          my-profile = {
            standards = {
              "coding-style.md" = "Use tabs for indentation...";
              "architecture.md" = "Follow clean architecture...";
            };
            product = {
              "vision.md" = "Our product vision...";
            };
            specs = {
              "feature-x.md" = "Implementation details...";
            };
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Activation script to clean up conflicting profile directories before linking
    home.activation.cleanAgentOsProfiles = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      # Check each profile directory that might conflict
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (profileName: _: ''
          profile_path="${config.home.homeDirectory}/agent-os/profiles/${profileName}"
          if [ -e "$profile_path" ]; then
            if [ -L "$profile_path" ]; then
              # Profile is a symlink, remove it entirely
              $DRY_RUN_CMD rm "$profile_path"
            else
              # Profile is a regular directory, check subdirectories
              for dir in standards product specs; do
                path="$profile_path/$dir"
                if [ -L "$path" ]; then
                  # Subdirectory is a symlink, just unlink it
                  $DRY_RUN_CMD rm "$path"
                elif [ -e "$path" ]; then
                  # Subdirectory is regular, make writable and remove
                  $DRY_RUN_CMD chmod -R u+w "$path" 2>/dev/null || true
                  $DRY_RUN_CMD rm -rf "$path"
                fi
              done
            fi
          fi
        '') cfg.profiles
      )}
    '';

    home.file = {
      # Install the agent-os data directory
      "agent-os/config.yml".source = configYaml;

      # Symlink scripts (read-only is fine)
      "agent-os/scripts".source = "${cfg.package}/share/agent-os/scripts";
      "agent-os/CHANGELOG.md".source = "${cfg.package}/share/agent-os/CHANGELOG.md";
      "agent-os/LICENSE".source = "${cfg.package}/share/agent-os/LICENSE";
      "agent-os/README.md".source = "${cfg.package}/share/agent-os/README.md";
    }
    // (
      # Generate profile files from Nix configuration
      lib.foldl' (
        acc: profileName:
        let
          profile = cfg.profiles.${profileName};

          # Helper to create directory content, optionally merging with package defaults
          mkProfileDir =
            dirName: files: mergeWithDefault:
            if files == { } && !mergeWithDefault then
              { }
            else
              {
                "agent-os/profiles/${profileName}/${dirName}".source = pkgs.runCommand "agent-os-${profileName}-${dirName}" { } ''
                  mkdir -p $out
                  ${lib.optionalString mergeWithDefault ''
                    # Copy default content from package if it exists
                    if [ -d "${cfg.package}/share/agent-os/profiles/${profileName}/${dirName}" ]; then
                      cp -r "${cfg.package}/share/agent-os/profiles/${profileName}/${dirName}"/* $out/ || true
                      chmod -R u+w $out
                    fi
                  ''}
                  ${lib.concatStringsSep "\n" (
                    lib.mapAttrsToList (name: content: ''
                      # Create parent directories for nested paths
                      mkdir -p $out/$(dirname ${lib.escapeShellArg name})
                      cat > $out/${lib.escapeShellArg name} <<'EOF'
                      ${content}
                      EOF
                    '') files
                  )}
                '';
              };

          # If profile is empty, use the default from the package
          useDefault = profile.standards == { } && profile.product == { } && profile.specs == { };
          # Check if we need to merge with defaults (default profile with custom content)
          mergeWithDefault = profileName == "default" && !useDefault;
        in
        if useDefault && profileName == "default" then
          acc
          // {
            "agent-os/profiles/default".source = "${cfg.package}/share/agent-os/profiles/default";
          }
        else
          acc
          // (mkProfileDir "standards" profile.standards mergeWithDefault)
          // (mkProfileDir "product" profile.product mergeWithDefault)
          // (mkProfileDir "specs" profile.specs mergeWithDefault)
      ) { } (lib.attrNames cfg.profiles)
    );

    # Add shell aliases for convenience
    programs.bash.shellAliases = mkIf config.programs.bash.enable {
      agent-os = "~/agent-os/scripts/project-install.sh";
    };

    programs.zsh.shellAliases = mkIf config.programs.zsh.enable {
      agent-os = "~/agent-os/scripts/project-install.sh";
    };
  };
}
