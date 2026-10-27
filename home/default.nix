{
  config,
  pkgs,
  pkgs-unstable,
  neovim-nightly-overlay,
  ...
}:
let
  homeManager = "${config.dotfiles.path}/home";
  link = config.lib.file.mkOutOfStoreSymlink;
  l = x: link homeManager + "/${x}";
  localPkgs = import ../pkgs { inherit pkgs; };
in
{
  imports = [
    ./dotfiles-path.nix
    ./git.nix
    ./fish.nix
    ./rex.nix
    ./tmux.nix
    ./fonts.nix
  ];

  home.username = "maxrn";
  home.homeDirectory = "/Users/${config.home.username}";

  home.stateVersion = "25.05";

  home.packages =
    let
      unstable = with pkgs-unstable; [
        bun
      ];
      stable = with pkgs; [
        # programming langs
        rustup
        nixd
        fnm
        nixfmt
        lua-language-server
        uv

        # CLIs
        bat
        btop
        curl
        wget
        fd
        fastfetch
        ripgrep
        tree
        jq
        difftastic
        hyperfine
        tokei # better SLOC estimater than cloc
        lazygit

        # other tools
        #(ffmpeg-full.override { withUnfree = true; })
        yt-dlp
        dive # because everytime I need it I have to re-download it again
        # and nix NEVER caches the stupid flake WHAT
        gh
        shellcheck
      ];
    in
    stable
    ++ unstable
    ++ [ neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default ]
    ++ [
      localPkgs.pi
      localPkgs.secretive
      (pkgs.writeShellApplication {
        name = "tmux-sessionizer";
        runtimeInputs = [
          pkgs.fzf
          pkgs.tmux
        ];
        text = ''
          if [[ $# -eq 1 ]]; then
              selected=$1
          else
              # A missing directory or a cancelled fzf just means "nothing selected".
              selected=$(find ~/work ~/code ~/uni ~/notes -mindepth 1 -maxdepth 1 -type d | fzf --tmux --color gutter:-1) || true
          fi

          if [[ -z $selected ]]; then
              exit 0
          fi

          selected_name=$(basename "$selected" | tr . _)

          if ! tmux has-session -t="$selected_name" 2> /dev/null; then
              tmux new-session -ds "$selected_name" -c "$selected"
          fi

          tmux switch-client -t "$selected_name"
        '';
      })
      (pkgs.writeShellApplication {
        name = "ask-gpt";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          read -r -p "Ask ChatGPT: " question
          url_encoded=$(printf '%s' "$question" | jq -sRr @uri)
          open "https://chatgpt.com/?q=$url_encoded"
        '';
      })
      (pkgs.writeShellApplication {
        name = "ask-tldr";
        runtimeInputs = [ pkgs.tldr ];
        text = ''
          read -r -a topic -p "Enter CLI/programming lang: "
          tldr "''${topic[@]}"
        '';
      })
    ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/nvim".source = l "dotfiles/nvim";
    ".config/ghostty".source = l "dotfiles/ghostty";
    ".config/fish/themes".source = l "dotfiles/fish/themes";
    ".pi/agent/keybindings.json".source = l "dotfiles/pi/keybindings.json";
  };

  # TODO: Maybe this belongs to nix-darwin?
  home.sessionVariables = {
    EDITOR = "nvim";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  home.preferXdgDirectories = true;

  home.shellAliases = {
    vim = "nvim";
    gdp = "git diff -p";
    glp = "git log -p";
    gsp = "git diff --staged -p";
    gbl = "git branch --list";
    gnew = "git switch -c";
    gs = "git status";
    dbu = "docker compose up -d --build";
    fzvim = "fzf | xargs nvim";
    ll = "ls -lah";
    cd = "z";
    br = "bun run";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "./node_modules/.bin"
    "$HOME/go/bin"
    "/opt/homebrew/bin"
    "$HOME/.cargo/bin"
  ];

  programs = {
    fzf = {
      enable = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home-manager.enable = true;

    eza = {
      enable = true;
    };
    zoxide = {
      enable = true;
    };
  };
}
