{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  config,
}:
buildDotnetModule rec {
  pname = "autotag";
  version = "3.5.5";

  src = fetchFromGitHub {
    owner = "jamerst";
    repo = "AutoTag";
    rev = "v${version}";
    hash = "sha256-etOpNzDJBBVv6g0Zmp4s8PTIKiuo+tTDM5dNgCWhg4M=";
  };

  projectFile = [
    "./AutoTag.CLI/AutoTag.CLI.csproj"
    "./AutoTag.Core/AutoTag.Core.csproj"
  ];
  nugetDeps = ./deps.nix; # see "Generating and updating NuGet dependencies" section for details

  dotnet-sdk = dotnetCorePackages.sdk_7_0;
  dotnet-runtime = dotnetCorePackages.runtime_7_0;

  patchPhase = ''
    cp ${config.age."packages/autotag/Keys.cs.age".path} ./AutoTag.CLI/Keys.cs
    ls ./AutoTag.CLI/
  '';

  executables = ["autotag"]; # This wraps "$out/lib/$pname/foo" to `$out/bin/foo`.

  packNupkg = true; # This packs the project as "foo-0.1.nupkg" at `$out/share`.
}
