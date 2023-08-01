{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs,
  extraFlags ? [],
}:
buildNpmPackage {
  pname = "arRPC";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "OpenAsar";
    repo = "arRPC";
    rev = "bfcba7e3d6e6f7301a5699c4a1eb10c968e7b568";
    hash = "sha256-P+tfoUlofQ05N1t9dtD12EgzKVs1t15wj/u5zzCxs7Q=";
  };

  dontNpmBuild = true;

  npmDepsHash = "sha256-ZgoxPBOxdi/Jd7ZQaow56gZchDHQpXuLJjbvcsy/pqA=";

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
    description = "An open implementation of Discord's local RPC servers";
    homepage = "https://github.com/OpenAsar/arRPC";
    changelog = "https://github.com/OpenAsar/arRPC/blob/${version}/changelog.md";
    license = licenses.mit;
    maintainers = with maintainers; [notashelf];
  };
}
