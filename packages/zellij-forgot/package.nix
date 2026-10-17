{
  lib,
  callPackage,
  fetchFromGitHub,
}:
let
  buildZellijPlugin = callPackage ../../lib/build-zellij-plugin.nix { };
in
buildZellijPlugin rec {
  pname = "zellij-forgot";
  version = "0.4.2";
  src = fetchFromGitHub {
    owner = "karimould";
    repo = "zellij-forgot";
    tag = version;
    hash = "sha256-QS09lC6yyUZA13PHERrdY/phfo1QoHAmRPpQUGL3pP8=";
  };
  cargoHash = "sha256-GR3bg6Rf6opb0jh8Hyv1y7gpsBh8nRExPjcGzIafHXg=";
  meta = {
    description = "Zellij plugin for showing your keybindings";
    homepage = "https://github.com/karimould/zellij-forgot";
    license = lib.licenses.mit;
  };
}
