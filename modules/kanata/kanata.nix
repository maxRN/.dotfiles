{ pkgs, ... }:
{
  imports = [ ./kanata-module.nix ];
  services.kanata = {
    enable = true;
    package = pkgs.kanata-with-cmd;
    keyboards.internal = {
      extraDefCfg = ''
        danger-enable-cmd yes
        process-unmapped-keys yes
      '';
      config = ''
        (defalias
            navleft (cmd open "rectangle://execute-action?name=left-half")
            navright (cmd open "rectangle://execute-action?name=right-half")
            navmax (cmd open "rectangle://execute-action?name=maximize")
            navdisplay (cmd open "rectangle://execute-action?name=next-display")
        )

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
            @cap a    s    d    f    g    h    j    k    l    @apps  @nav  \    ret
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

        ;; applications aliases
        (defalias
          o_safari (cmd open -a "Safari")
          o_ghostty (cmd open -a "Ghostty")
          o_obsidian (cmd open -a "Obsidian")
          o_intellij (cmd open -a "IntelliJ IDEA")
          o_slack (cmd open -a "Slack")
          o_xcode (cmd open -a "Xcode")
        )

        (deflayer applayer
            _  _   _    _    _    _    _    _   _   _   _   _   _
            _ _  _    _    _    _    _    _    _    _    _    _    _    _
            _  @o_slack _    _    _    _    _    _    _    _    _    _    _
            _ @o_safari @o_ghostty @o_obsidian @o_intellij  g  h  j k l @apps    _    _    _
            _ _  _    @o_xcode  _    _    _    _    _    _    _    _    _
            _   _ _ _           _            _ _
        )

        (deflayer navlayer
            _  _   _    _    _    _    _    _   _   _   _   _   _
            _ _  _    _    _    _    _    _    _    _    _    _    _    _
            _  _    _    _    _  @navdisplay  _    _    _    _    _    _    _
            _ a @navleft @navright @navmax  g  h  j k l _  @nav  _    _
            _ _  _    _    _    _    _    _    _    _    _    _    _
            _   _ _ _           _            _ _
        )

        (defalias
          cap (tap-hold-press 200 200 esc lctl)
          grv (tap-hold-press 200 200 grv (layer-toggle mylayer))
          esc (tap-hold-press 200 200 esc (layer-toggle mylayer))
          apps (tap-hold-press 200 200 ; (layer-toggle applayer))
          nav (tap-hold 10 200 ' (layer-toggle navlayer))
        )
      '';
    };
  };
}
