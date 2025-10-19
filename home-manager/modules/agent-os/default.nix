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

  config =
    let
      # Build a merged agent-os directory in the Nix store
      # This combines the base package with user-defined overrides
      mergedAgentOs = pkgs.runCommand "agent-os-merged" { } ''
        # Start with a copy of the base package
        cp -r ${cfg.package}/share/agent-os $out
        chmod -R u+w $out

        # Replace config.yml with user configuration
        cp ${configYaml} $out/config.yml

        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (profileName: profile: ''
            # Handle profile: ${profileName}
            profile_dir="$out/profiles/${profileName}"

            # Create profile directories if they don't exist
            mkdir -p "$profile_dir"/{standards,product,specs}

            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: content: ''
                # Add/override: standards/${name}
                mkdir -p "$profile_dir/standards/$(dirname ${lib.escapeShellArg name})"
                cat > "$profile_dir/standards/${lib.escapeShellArg name}" <<'EOF'
                ${content}
                EOF
              '') profile.standards
            )}

            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: content: ''
                # Add/override: product/${name}
                mkdir -p "$profile_dir/product/$(dirname ${lib.escapeShellArg name})"
                cat > "$profile_dir/product/${lib.escapeShellArg name}" <<'EOF'
                ${content}
                EOF
              '') profile.product
            )}

            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: content: ''
                # Add/override: specs/${name}
                mkdir -p "$profile_dir/specs/$(dirname ${lib.escapeShellArg name})"
                cat > "$profile_dir/specs/${lib.escapeShellArg name}" <<'EOF'
                ${content}
                EOF
              '') profile.specs
            )}
          '') cfg.profiles
        )}

        # Patch all scripts to use this merged directory
        find $out/scripts -name "*.sh" -type f -exec sed -i \
          "s|BASE_DIR=\"/nix/store/[^/]*/share/agent-os\"|BASE_DIR=\"$out\"|g" {} \;
      '';

      # Create wrapper scripts that use the merged store path
      wrappedAgentOs = pkgs.runCommand "agent-os-wrapped" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        mkdir -p $out/bin

        # Create wrappers for all scripts
        for script in ${mergedAgentOs}/scripts/*.sh; do
          scriptName=$(basename "$script" .sh)
          makeWrapper "$script" "$out/bin/agent-os-$scriptName" \
            --prefix PATH : ${lib.makeBinPath cfg.package.buildInputs}
        done

        # Create a main 'agent-os' command that points to project-install
        ln -s $out/bin/agent-os-project-install $out/bin/agent-os
      '';
    in
    mkIf cfg.enable {
      home.packages = [ wrappedAgentOs ];

      # Add shell aliases for convenience
      programs.bash.shellAliases = mkIf config.programs.bash.enable {
        agent-os = "agent-os-project-install";
      };

      programs.zsh.shellAliases = mkIf config.programs.zsh.enable {
        agent-os = "agent-os-project-install";
      };
    };
}
