{
  lib,
  callPackage,
  fetchFromGitHub,
}:
let
  buildZellijPlugin = callPackage ../../lib/build-zellij-plugin.nix { };
in
buildZellijPlugin rec {
  pname = "room";
  version = "1.2.1";
  src = fetchFromGitHub {
    owner = "rvcas";
    repo = "room";
    tag = "v${version}";
    hash = "sha256-KHCt4U0uqK/qkTGq2/Jf5bqBBhVDqAgFh80RPpU/KY0=";
  };
  cargoHash = "sha256-CtaMzE72YV/DPPhjxL6LCvA03J8MneSOnMdy4mkyXvE=";
  meta = {
    description = "Zellij plugin for quickly searching and switching tabs";
    homepage = "https://github.com/rvcas/room";
    license = lib.licenses.mit;
  };
}
