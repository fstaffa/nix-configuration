{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/agent-os
    ../../modules/claude
  ];

  home.packages = with pkgs; [
    dotnet-sdk_10
    csharpier

    go
    gopls
    gotools
    gore
    goreleaser
    gomodifytags
    gotests
    golangci-lint
    cobra-cli

    terraform
    kubectl
    kubeseal
    kubernetes-helm
    kustomize
    kubelogin-oidc
    argocd
    skopeo
    talosctl
    omnictl

    gh
    glab

    nixd
    nixos-anywhere

    claude-code-bin
    opencode
    github-copilot-cli

    eas-cli

    tokei
    graphviz
    pandoc
    dockfmt
    shellcheck
    shfmt
  ];

  home.sessionPath = [ "$HOME/.dotnet/tools" ];
  home.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet";
  }
  // lib.optionalAttrs pkgs.stdenv.isDarwin {
    # Use nix cacert bundle so Go programs (e.g. glab) can verify TLS in sandbox
    # without needing access to the macOS keychain
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  programs = {
    agent-os = {
      enable = true;
    };

    zsh.initContent = ''
      [[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"
    '';
  };
}
