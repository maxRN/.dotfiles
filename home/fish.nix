{
  programs = {
    fzf = {
      enableFishIntegration = true;
    };
    direnv = {
      # Just for documentation. direnv is automatically loaded in fish.
      # https://github.com/nix-community/home-manager/issues/2357
      # enableFishIntegration = true;
    };
    zoxide = {
      # same here... apparently this is enabled by default?? Is fish just OP?
      enableFishIntegration = true;
    };
    ghostty = {
      # enableFishIntegration = true;
    };

    fish = {
      enable = true;
      shellInit = ''
        abbr --add k kubectl

        function nshell
            # nixpkgs-24.11-darwin as of 2024-12-15
            nix shell "nixpkgs/cf14ff3b4e8e716346d6f1e8ee6d811c0c0838a7#$argv[1]"
        end

        # get .. / ... / .... functionality
        function multicd
            echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
        end
        abbr --add dotdot --regex '^\.\.+$' --function multicd

        eval "$(fnm env --use-on-cd)"

        set fish_greeting

        # Setting up for using SSH. Am I using this wrong?

        setenv SSH_ENV $HOME/.ssh/environment

        function start_agent
            echo "Initializing new SSH agent ..."
            ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
            echo "succeeded"
            chmod 600 $SSH_ENV
            . $SSH_ENV > /dev/null
            ssh-add
        end

        function test_identities
            ssh-add -l | grep "The agent has no identities" > /dev/null
            if [ $status -eq 0 ]
                ssh-add
                if [ $status -eq 2 ]
                    start_agent
                end
            end
        end

        if [ -n "$SSH_AGENT_PID" ]
            ps -ef | grep $SSH_AGENT_PID | grep ssh-agent > /dev/null
            if [ $status -eq 0 ]
                test_identities
            end
        else
            if [ -f $SSH_ENV ]
                . $SSH_ENV > /dev/null
            end
            ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep ssh-agent > /dev/null
            if [ $status -eq 0 ]
                test_identities
            else
                start_agent
            end
        end

        # not sure if this is necessary tbh, but it means the shell integration works more reliably
        # https://ghostty.org/docs/features/shell-integration#manual-shell-integration-setup
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"

        # Prompt
        fish_config prompt choose arrow
        fish_config theme choose my
      '';
    };
  };
}
