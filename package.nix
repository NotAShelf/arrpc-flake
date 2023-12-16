{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs,
  extraFlags ? [],
}: let
  pname = "arRPC";
  version = "2023-12-14-unstable";
in
  buildNpmPackage {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "OpenAsar";
      repo = "arRPC";
      rev = "98879cae0565e6fce34e4cb6f544bf42c6a7e7c8";
      hash = "sha256-Q46nuAFj/G5JyXAwSlV+Eh3CLO8/UYwrBX19sDUKgUg=";
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
