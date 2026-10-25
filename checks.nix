# nix flake check: every wrapper builds and its program sees its config.
{
  pkgs,
  packages,
  mkPackages,
}:
let
  inherit (pkgs) lib;

  # what a user of the flake would set, once for every package
  identity = {
    name = "Some One";
    email = "some.one@example.com";
  };
  custom = mkPackages { inherit pkgs identity; };

  check =
    name: script:
    pkgs.runCommand "check-${name}" { } ''
      export HOME=$(mktemp -d)
      ${script}
      touch $out
    '';
in
{
  inherit (packages) btop;

  bat = check "bat" ''
    bat=${lib.getExe packages.bat}
    export COLORTERM=truecolor
    echo 'x = 1' > file.py
    test "$($bat --color=always file.py)" = "$($bat --color=always --theme='Catppuccin Mocha' file.py)"
  '';

  gdb = check "gdb" ''
    # the init file in the home directory is ignored, gef has the same config
    mkdir -p ~/.config/gdb
    echo 'set print asm-demangle off' > ~/.config/gdb/gdbinit
    for gdb in ${packages.gdb}/bin/gdb ${packages.gdb}/bin/gef; do
      $gdb -batch -ex 'show print asm-demangle' | grep -q ' on\.$'
      $gdb -batch -ex 'show history filename' | grep -qF "\"$HOME/.local/share/gdb_history\""
    done
    ${packages.gdb}/bin/gef -batch -ex 'gef help' | grep -q 'GEF - GDB Enhanced Features'
    # gef's settings are saved to and restored from the XDG config directory
    ${packages.gdb}/bin/gef -batch -ex 'gef config context.nb_lines_code 3' -ex 'gef save'
    grep -q 'nb_lines_code = 3' ~/.config/gef.rc
    test "$(${packages.gdb}/bin/gef -batch -ex 'python print(gef.config["context.nb_lines_code"])' | tail -1)" = 3
    mkdir xdg
    XDG_CONFIG_HOME=$PWD/xdg ${packages.gdb}/bin/gef -batch -ex 'gef save'
    test -f xdg/gef.rc
  '';

  git = check "git" ''
    git=${lib.getExe packages.git}
    # the pager is delta, told to read the wrapper's config
    $git config core.pager | grep -q '^delta --config '
    $git -c 'alias.has-delta=!command -v delta' has-delta
    # delta knows the syntax theme
    echo a > a; echo b > b
    $git -c 'alias.delta=!delta' delta a b 2> err || true
    ! grep -i 'unknown theme' err
  '';

  jujutsu = check "jujutsu" ''
    jj=${lib.getExe packages.jujutsu}
    $jj config get templates.draft_commit_description | grep -q 'JJ: ignore-rest'
  '';

  identity = check "identity" ''
    test "$(${lib.getExe custom.git} config user.name)" = ${lib.escapeShellArg identity.name}
    test "$(${lib.getExe custom.git} config user.email)" = ${lib.escapeShellArg identity.email}
    test "$(${lib.getExe custom.jujutsu} config get user.name)" = ${lib.escapeShellArg identity.name}
    test "$(${lib.getExe custom.jujutsu} config get user.email)" = ${lib.escapeShellArg identity.email}
    # packages without the option are unaffected
    test ${custom.bat} = ${packages.bat}
  '';

  kitty = check "kitty" ''
    ${lib.getExe packages.kitty} +runpy '
    from kitty.cli import create_default_opts
    opts = create_default_opts()
    assert opts.background_opacity == 0.95, opts.background_opacity
    assert opts.shell == "fish", opts.shell
    '
  '';

  starship = check "starship" ''
    starship=${lib.getExe packages.starship}
    $starship print-config hostname | grep -q 'format = "\[$hostname\](bold blue) "'
    # the shell integration runs the wrapper, not the unwrapped starship
    for shell in bash fish zsh; do
      $starship init $shell --print-full-init | grep -o '/nix/store/[^ "]*/bin/starship' | sort -u > paths
      test "$(cat paths)" = "${packages.starship}/bin/starship"
    done
  '';

  zellij = check "zellij" ''
    zellij=${lib.getExe packages.zellij}
    export XDG_RUNTIME_DIR=$(mktemp -d)
    $zellij setup --check | grep -q 'CONFIG FILE.*Well defined'
    # the base layout is the default, with zjstatus from the store
    $zellij attach --create-background check
    trap '$zellij kill-all-sessions -y' EXIT
    for _ in $(seq 50); do
      $zellij -s check action dump-layout > layout 2>/dev/null && grep -q zjstatus layout && break
      sleep 0.2
    done
    grep -q 'plugin location="file:${pkgs.zellijPlugins.zjstatus}"' layout
  '';
}
