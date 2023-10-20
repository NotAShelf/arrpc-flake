{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs,
  extraFlags ? [],
}:
buildNpmPackage {
  pname = "arRPC";
  version = "2023-19-17-unstable";

  src = fetchFromGitHub {
    owner = "OpenAsar";
    repo = "arRPC";
    rev = "89f4da610ccfac93f461826a446a17cd3b23953d";
    hash = "sha256-M4oQBpY/t+MEyvCienQE/GU2JfFzPKI9U2jQTRZQs4I=";
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
    mainProgram = "arRPC";
    description = "Open Discord RPC server for atypical setups ";
    homepage = "https://github.com/OpenAsar/arRPC";
    changelog = "https://github.com/OpenAsar/arRPC/blob/${version}/changelog.md";
    license = licenses.mit;
    maintainers = with maintainers; [notashelf];
  };
}
