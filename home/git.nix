{ lib, config, ... }:
{
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f ~/.gitconfig
  '';

  programs.delta = {
    enable = true; # try new differ https://github.com/dandavison/delta
    enableGitIntegration = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;

    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    ignores = [
      "workspace.code-workspace"
      ".DS_Store"
      ".envrc"
      ".direnv/"
      ".quarkus/"
      ".venv/"
      "__pycache__/"
    ];

    includes = [
      {
        # use different email & name for work
        path = "~/work/.gitconfig";
        condition = "gitdir:~/work/";
      }
      {
        condition = "gitdir:~/uni/";
        path = "~/uni/.gitconfig";
      }
    ];

    settings = {
      user = {
        name = "Max Große";
        email = "max12.gro@gmail.com";
      };

      alias = {
        # common aliases
        cm = "commit -m";
        ca = "commit -am";
        cn = "commit --amend --no-edit";
        dc = "diff --cached";

        dft = "difftool";
        dlog = "-c diff.external=difft log -p --ext-diff";

        # aliases for submodule
        update = "submodule update --init --recursive";
        foreach = "submodule foreach";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;

      # https://jvns.ca/blog/2024/02/16/popular-git-config-options/#merge-conflictstyle-zdiff3
      merge.conflictstyle = "zdiff3";
      diff.algorithm = "histogram";
      branch.sort = "-committerdate";

      diff.colorMoved = "default";
      merge.tool = "nvim";
      credential.helper = "osxkeychain";
      core.excludesFile = "${config.home.homeDirectory}/.config/git/ignore";
      rerere.enabled = true;
    };
  };
}
