{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs,
  extraFlags ? [],
}: let
  pname = "arRPC";
  version = "2023-11-01-unstable";
in
  buildNpmPackage {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "OpenAsar";
      repo = "arRPC";
      rev = "c902d82addb4a84ede7e8dd4ccfe796570c05254";
      hash = "sha256-wuhFD8rQEyFz/u/Y4p5QHEsDB8b0UHOTl+QWKF4+wAQ=";
    };

    dontNpmBuild = true;
    npmDepsHash = "sha256-vxx0w6UjwxIK4cgpivtjNbIgkb4wKG4ijSHdP/FeQZ4=";

    preInstall = ''
      mkdir -p $out/lib/node_modules/arRPC/
    '';

    postInstall = ''
      cp -rf src/* ext/* $out/lib/node_modules/arRPC/
    '';

    postFixup = ''
      ${nodejs}/bin/node --version
      makeWrapper ${nodejs}/bin/node $out/bin/arRPC \
        --add-flags $out/lib/node_modules/arrpc/src \
        --chdir $out/lib/node_modules/arrpc/src \
        ${lib.concatStringsSep " " (map (flag: "--add-flags ${flag}") extraFlags)}
    '';

    meta = with lib; {
      changelog = "https://github.com/OpenAsar/arRPC/blob/main/changelog.md";
      description = "Open Discord RPC server for atypical setups ";
      homepage = "https://github.com/OpenAsar/arRPC";
      license = licenses.mit;
      maintainers = with maintainers; [notashelf];
      mainProgram = pname;
    };
  }
