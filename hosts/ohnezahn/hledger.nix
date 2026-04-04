{
  pkgs-unstable,
  ...
}:
{
  home.sessionVariables = {
    LEDGER_FILE = "~/code/finance/.hledger.journal";
  };

  home.packages =
    let
      unstable = with pkgs-unstable; [
        hledger
      ];
    in
    unstable;
}
