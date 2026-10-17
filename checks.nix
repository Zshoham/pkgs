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

  git = check "git" ''
    git=${lib.getExe packages.git}
    test "$($git config core.pager)" = delta
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
