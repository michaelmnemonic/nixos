{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  extra-cmake-modules,
  wrapQtAppsHook,
  # Qt
  qtbase,
  qtdeclarative,
  qtmqtt,
  # KF6 / kdePackages
  bluez-qt,
  kcmutils,
  kconfig,
  kcoreaddons,
  kdbusaddons,
  kglobalaccel,
  kidletime,
  ki18n,
  kio,
  knotifications,
  kservice,
  pulseaudio-qt,
  solid,
  # other libraries
  systemd, # libudev, for the gamepad integration
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "kiot";
  version = "21417a3362296442366b953cf3a47c4afaa3f618";

  src = fetchFromGitHub {
    owner = "davidedmundson";
    repo = "kiot";
    rev = finalAttrs.version;
    hash = "sha256-TX+NBiegocrEA/w/wVvfR9ggiikVhm1kznD8RV1i21U=";
  };

  # Needs to be called with a scope providing Qt6/KF6, e.g.
  #   kdePackages.callPackage ./pkgs/kiot { }
  # because it requires qtmqtt and the KF6 set.
  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtdeclarative
    qtmqtt
    bluez-qt
    kcmutils
    kconfig
    kcoreaddons
    kdbusaddons
    kglobalaccel
    kidletime
    ki18n
    kio
    knotifications
    kservice
    pulseaudio-qt
    solid
    systemd
  ];

  meta = {
    description = "KDE Internet of Things desktop integration for home automation";
    longDescription = ''
      KIOT is a background daemon that exposes useful information and actions
      from your desktop session to a home automation controller such as Home
      Assistant via MQTT.
    '';
    homepage = "https://github.com/davidedmundson/kiot";
    # Upstream repository carries no license file; do not redistribute.
    mainProgram = "kiot";
    platforms = lib.platforms.linux;
  };
})
