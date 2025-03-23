{ pkgs, ... }: let
  inherit (pkgs) lib;
in pkgs.stdenv.mkDerivation rec {
  pname = "kmymoney";
  version = "5.1.92";

  src = pkgs.fetchurl {
    url = "https://invent.kde.org/office/kmymoney/-/archive/v${version}/kmymoney-v${version}.tar.gz";
    sha256 = "sha256-YmgqpXmA38CeQJKMqIUlYIp82s4KEDHhptgf1yZjmXo=";
  };

  meta = {
    description = "Personal finance manager for KDE";
    mainProgram = "kmymoney";
    homepage = "https://kmymoney.org/";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2Plus;
  };
}
