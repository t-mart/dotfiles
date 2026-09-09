{ pkgs, ... }:
{
  home = {
    username = "tim";
    homeDirectory = "/home/tim";
    stateVersion = "26.05";
    packages = with pkgs; [
      brotli
      dust
      erdtree
      fclones
      fd
      fzf
      gping
      gum
      gzip
      lazydocker
      ncdu
      ouch
      procs
      ranger
      trippy
      unrar
      uv
      vivid
      xz
      zip
      zstd
    ];
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "bat";
      RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep.conf";
    };
  };

  programs = {
    home-manager.enable = true;
    atuin = {
      enable = true;
      enableNushellIntegration = true;
    };
    bat.enable = true;
    btop.enable = true;
    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
    fastfetch.enable = true;
    fzf.enable = true;
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        dark = true;
        navigate = true;
      };
    };
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "Tim Martin";
          email = "tim@timmart.in";
          signingKey = "19A52622B91D5DE3";
        };
        branch = {
          autosetuprebase = "always";
          sort = "-committerdate";
        };
        commit = {
          gpgSign = true;
          verbose = true;
        };
        core.editor = "nvim";
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };
        fetch = {
          all = true;
          prune = true;
          pruneTags = true;
        };
        github.user = "t-mart";
        init.defaultBranch = "master";
        merge.conflictstyle = "zdiff3";
        push = {
          autoSetupRemote = true;
          default = "current";
          followTags = true;
          gpgSign = "if-asked";
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
        rerere = {
          autoupdate = true;
          enabled = true;
        };
        tag = {
          gpgSign = true;
          sort = "version:refname";
        };
      };
    };
    nushell = {
      enable = true;
      shellAliases = {
        cat = "bat";
        less = "bat";
        vi = "nvim";
        vim = "nvim";
      };
    };
    oh-my-posh = {
      enable = true;
      enableNushellIntegration = true;
    };
    ripgrep = {
      enable = true;
      arguments = [ "--hidden" ];
    };
    zoxide = {
      enable = true;
      enableNushellIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
}
