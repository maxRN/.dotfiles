{
  config,
  lib,
  pkgs,
  ...
}:
let
  aerospaceAsPrimaryUser = pkgs.writeShellScript "aerospace-as-primary-user" ''
    exec /usr/bin/sudo -H -u ${lib.escapeShellArg config.system.primaryUser} -- \
      ${lib.getExe config.services.aerospace.package} "$@"
  '';
in
{
  imports = [ ../../modules/kanata/kanata-module.nix ];
  services.kanata = {
    enable = true;
    package = pkgs.kanata-with-cmd;
    keyboards.internal = {
      extraDefCfg = ''
        danger-enable-cmd yes
        process-unmapped-keys yes
      '';
      config = ''
        (defsrc
            esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
            IntlBackslash 1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]
            caps a    s    d    f    g    h    j    k    l    ;    '    \    ret
            lsft Backquote  z    x    c    v    b    n    m    ,    .    /    rsft
            fn   lctl lalt lmet           spc            rmet ralt
        )

        (deflayer base
            ;; everything is exactly the same, only the f-row is changed.
            ;; you can of course change any of the other mappings.
            @esc  🔅   🔆    ✗    ✗    ✗    ✗    ◀◀   ▶⏸   ▶▶   🔇   🔉   🔊
            @grv 1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]
            @cap a    s    d    f    g    h    j    k    l    @apps  '  \    ret
            lsft lsft  z    x    c    v    b    n    m    ,    .    /    rsft
            lctl   lctl lalt lmet           spc            rmet ralt
        )

        (deflayer mylayer
            @esc  _   _    _    _    _    _    _   _   _   _   _   _
            @grv lrld  lrld-next    _    _    _    _    _    _    _    _    _    _    _
            _  _    _    _    _    _    _    _    _    _    _    _    _
            _ _    _    _    _    _    left    down    up    right    _    _    _    _
            _ _  _    _    _    _    _    _    _    _    _    _    _
            _   _ _ _           _            _ _
        )

        (defalias
          ws1 (cmd ${aerospaceAsPrimaryUser} workspace 1)
          ws2 (cmd ${aerospaceAsPrimaryUser} workspace 2)
          ws3 (cmd ${aerospaceAsPrimaryUser} workspace 3)
          ws4 (cmd ${aerospaceAsPrimaryUser} workspace 4)
          ws5 (cmd ${aerospaceAsPrimaryUser} workspace 5)
          ws6 (cmd ${aerospaceAsPrimaryUser} workspace 6)
          ws7 (cmd ${aerospaceAsPrimaryUser} workspace 7)
          ws8 (cmd ${aerospaceAsPrimaryUser} workspace 8)
          ws9 (cmd ${aerospaceAsPrimaryUser} workspace 9)
          ws11 (cmd ${aerospaceAsPrimaryUser} workspace 11)
          ws12 (cmd ${aerospaceAsPrimaryUser} workspace 12)
          ws13 (cmd ${aerospaceAsPrimaryUser} workspace 13)
          ws14 (cmd ${aerospaceAsPrimaryUser} workspace 14)
          focus_left (cmd ${aerospaceAsPrimaryUser} focus left)
          focus_down (cmd ${aerospaceAsPrimaryUser} focus down)
          focus_up (cmd ${aerospaceAsPrimaryUser} focus up)
          focus_right (cmd ${aerospaceAsPrimaryUser} focus right)
        )

        (deflayer applayer
            _  _   _    _    _    _    _    _   _   _   _   _   _
            _ _  _    _    _    _    _    _    _    _    _    _    _    _
            _  @ws6 @ws7    @ws8  @ws9   t    _    _    _    _    _    _    _
            _ @ws1 @ws2 @ws3 @ws4  @ws5  @focus_left  @focus_down @focus_up @focus_right @apps    _    _    _
            _ _  @ws11  @ws12 @ws13 @ws14   _    _    _    _    _    _    _
            _   _ _ _           _            _ _
        )

        (defalias
          cap (tap-hold-press 200 200 esc lctl)
          grv (tap-hold-press 200 200 grv (layer-toggle mylayer))
          esc (tap-hold-press 200 200 esc (layer-toggle mylayer))
          apps (tap-hold-press 200 200 ; (layer-toggle applayer))
        )
      '';
    };
  };
}
