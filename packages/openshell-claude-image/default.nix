# OCI image for running Claude Code (on Bedrock) inside an OpenShell sandbox.
#   docker load < $(nix build .#openshell-claude-image --print-out-paths)
# The matching sandbox policy is exposed as passthru.policy, so the claude
# store path it binds Bedrock egress to always matches the image contents.
{
  lib,
  dockerTools,
  writeTextDir,
  writeText,
  bashInteractive,
  coreutils,
  findutils,
  gnugrep,
  gnused,
  gawk,
  diffutils,
  less,
  procps,
  which,
  git,
  gh,
  glab,
  curl,
  jq,
  ripgrep,
  awscli2,
  claude-code,
}:

let
  region = "eu-west-1";

  managedSettings = writeTextDir "etc/claude-code/managed-settings.json" (
    builtins.toJSON {
      env = {
        CLAUDE_CODE_USE_BEDROCK = "1";
        AWS_REGION = region;
        ANTHROPIC_DEFAULT_OPUS_MODEL = "eu.anthropic.claude-opus-5-5";
        ANTHROPIC_DEFAULT_SONNET_MODEL = "global.anthropic.claude-sonnet-5-5";
        ANTHROPIC_DEFAULT_HAIKU_MODEL = "eu.anthropic.claude-haiku-4-5-20251001-v1:0";
        ANTHROPIC_SMALL_FAST_MODEL = "eu.anthropic.claude-sonnet-5";
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
      };
      # OpenShell is the isolation boundary; Claude's own bubblewrap sandbox
      # can't run inside it (no user namespaces / capabilities).
      sandbox.enabled = false;
      permissions.defaultMode = "bypassPermissions";
      includeCoAuthoredBy = false;
    }
  );

  image = dockerTools.buildLayeredImage {
    name = "openshell-claude";
    tag = "latest";

    contents = [
      dockerTools.caCertificates
      dockerTools.usrBinEnv
      dockerTools.binSh
      managedSettings
      bashInteractive
      coreutils
      findutils
      gnugrep
      gnused
      gawk
      diffutils
      less
      procps
      which
      git
      gh
      glab
      curl
      jq
      ripgrep
      awscli2
      claude-code
    ];

    # OpenShell reads /etc/passwd from the image tar and rejects symlinks, so
    # these must be real files rather than store paths in contents.
    fakeRootCommands = ''
      mkdir -p etc
      printf 'root:x:0:0:root:/root:/bin/sh\nsandbox:x:1000:1000:sandbox:/sandbox:/bin/bash\n' > etc/passwd
      printf 'root:x:0:\nsandbox:x:1000:\n' > etc/group
      mkdir -p sandbox tmp
      chown 1000:1000 sandbox
      chmod 1777 tmp
    '';

    config = {
      User = "sandbox";
      WorkingDir = "/sandbox";
      # OpenShell's identity resolver creates a throwaway container and fails without one
      Cmd = [ "/bin/bash" ];
      Env = [
        "HOME=/sandbox"
        "PATH=/bin:/usr/bin"
        "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
        "AWS_REGION=${region}"
      ];
    };

    passthru.policy = writeText "openshell-claude-policy.yaml" (
      builtins.toJSON {
        version = 1;
        filesystem_policy = {
          include_workdir = true;
          read_only = [
            "/nix"
            "/bin"
            "/usr"
            "/etc"
            "/proc"
            "/dev/urandom"
          ];
          read_write = [
            "/sandbox"
            "/tmp"
            "/dev/null"
          ];
        };
        landlock.compatibility = "best_effort";
        network_policies = {
          bedrock = {
            name = "claude-bedrock";
            endpoints = [
              {
                host = "bedrock-runtime.${region}.amazonaws.com";
                port = 443;
                protocol = "rest";
                enforcement = "enforce";
                credential_binding.provider = "bedrock";
                credential_signing = "sigv4:body";
                signing_service = "bedrock";
                rules = [
                  {
                    allow = {
                      method = "POST";
                      path = "/model/**";
                    };
                  }
                ];
              }
              # control plane; Claude Code looks up inference profiles here
              {
                host = "bedrock.${region}.amazonaws.com";
                port = 443;
                protocol = "rest";
                enforcement = "enforce";
                credential_binding.provider = "bedrock";
                credential_signing = "sigv4";
                signing_service = "bedrock";
                rules = [
                  {
                    allow = {
                      method = "GET";
                      path = "/**";
                    };
                  }
                ];
              }
            ];
            # bin/claude is a makeBinaryWrapper ELF; the process that connects is the wrapped binary
            binaries = [ { path = "${claude-code}/bin/.claude-wrapped"; } ];
          };
        };
      }
    );

    meta.platforms = [ "x86_64-linux" ];
  };
in
image
