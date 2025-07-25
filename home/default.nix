{
  config,
  pkgs,
  pkgs-unstable,
  neovim-nightly-overlay,
  codelldb,
  ...
}:
let
  # needs to be absolute path. Important!
  homeManager = builtins.toPath "/Users/${userName}/code/.dotfiles/home";
  link = config.lib.file.mkOutOfStoreSymlink;
  l = x: link homeManager + "/${x}";
  userName = "maxrn";
in
{
  imports = [
    ./git.nix
    ./fish.nix
    ./tmux.nix
    ./ssh.nix
  ];

  home.username = userName;
  home.homeDirectory = "/Users/${userName}";

  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.packages =
    let
      unstable = with pkgs-unstable; [ ];
      stable = with pkgs; [
        # programming langs
        rustup
        nixd
        fnm
        nixfmt-rfc-style
        lua-language-server
        uv

        # CLIs
        bat
        btop
        curl
        wget
        fd
        neofetch
        ripgrep
        tree
        jq
        difftastic
        hyperfine
        tokei # better SLOC estimater than cloc
        lazygit

        # other tools
        #(ffmpeg-full.override { withUnfree = true; })
        tree-sitter
        yt-dlp
        dive # because everytime I need it I have to re-download it again
        # and nix NEVER caches the stupid flake WHAT
        gh
        shellcheck
      ];
    in
    stable
    ++ unstable
    ++ [ neovim-nightly-overlay.packages.${pkgs.system}.default ]
    ++ [ codelldb.outputs.packages.${pkgs.system}.codelldb ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/nvim".source = l "dotfiles/nvim";
    ".config/bat".source = l "dotfiles/bat";
    ".config/ghostty".source = l "dotfiles/ghostty";
    ".config/fish/themes".source = l "dotfiles/fish/themes";
    ".config/kanata".source = l "dotfiles/kanata";
  };

  # TODO: Maybe this belongs to nix-darwin?
  home.sessionVariables = {
    EDITOR = "nvim";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    # TODO: Ugly hack to get man working correctly. Yes, I know there is doubling in there. Yes, I know I have hardcoded my user name.
    MANPATH = "/Users/maxrn/.local/state/fnm_multishells/68242_1731052803936/share/man:/etc/profiles/per-user/maxrn/share/man:/run/current-system/sw/share/man:/nix/var/nix/profiles/default/share/man:/usr/local/share/man:/System/Cryptexes/App/usr/share/man:/usr/share/man:/opt/X11/share/man:/Library/TeX/texbin/man:/Users/maxrn/.local/state/fnm_multishells/44311_1730708868618/share/man:/Users/maxrn/Library/Python/3.10/share/man:/opt/homebrew/share/man:/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/share/man:/Applications/Xcode.app/Contents/Developer/usr/share/man:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man:/Users/maxrn/.local/state/fnm_multishells/68242_1731052803936/share/man:/etc/profiles/per-user/maxrn/share/man:/run/current-system/sw/share/man:/nix/var/nix/profiles/default/share/man:/usr/local/share/man:/System/Cryptexes/App/usr/share/man:/usr/share/man:/opt/X11/share/man:/Library/TeX/texbin/man:/Users/maxrn/.local/state/fnm_multishells/44311_1730708868618/share/man:/Users/maxrn/Library/Python/3.10/share/man:/opt/homebrew/share/man:echo:/Users/maxrn/.local/state/fnm_multishells/68242_1731052803936/share/man:/etc/profiles/per-user/maxrn/share/man:/run/current-system/sw/share/man:/nix/var/nix/profiles/default/share/man:/usr/local/share/man:/System/Cryptexes/App/usr/share/man:/usr/share/man:/opt/X11/share/man:/Library/TeX/texbin/man:/Users/maxrn/.local/state/fnm_multishells/44311_1730708868618/share/man:/Users/maxrn/Library/Python/3.10/share/man:/opt/homebrew/share/man:/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/share/man:/Applications/Xcode.app/Contents/Developer/usr/share/man:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man:/Users/maxrn/.local/state/fnm_multishells/68242_1731052803936/share/man:/etc/profiles/per-user/maxrn/share/man:/run/current-system/sw/share/man:/nix/var/nix/profiles/default/share/man:/usr/local/share/man:/System/Cryptexes/App/usr/share/man:/usr/share/man:/opt/X11/share/man:/Library/TeX/texbin/man:/Users/maxrn/.local/state/fnm_multishells/44311_1730708868618/share/man:/Users/maxrn/Library/Python/3.10/share/man:/opt/homebrew/share/man";
  };

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
  };

  home.sessionPath = [
    "$HOME/bin"
    "$XDG_CONFIG_HOME/nix-darwin/home/dotfiles/scripts"
    "$HOME/.local/bin"
    "./node_modules/.bin"
    "$HOME/go/bin"
    "/opt/homebrew/bin"
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

  fonts.fontconfig.enable = true;
}
