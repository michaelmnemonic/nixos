{ lib
, fetchFromGitHub
, cmake
, ninja
, qt6
, bluez-qt
, pulseaudio-qt
, pkg-config
, extra-cmake-modules
, qt6-mqtt
, kf6
, wayland
, xorg
, libxkbcommon
, mesa
, openssl
, patchelf
, file
, makeDesktopItem
, ...
}:

let
  version = "21417a3";
  pname = "kiot";

  src = fetchFromGitHub {
    owner = "davidedmundson";
    repo = "kiot";
    rev = version;
    sha256 = lib.fakeSha256;
    fetchSubmodules = true;
  };

  # Qt6 dependencies
  qtDeps = with qt6; [
    qtbase
    qtdeclarative
    qt5compat
    qtsvg
    qtwayland
  ];

  # KF6 dependencies
  kf6Deps = with kf6; [
    bluezqt
    pulseaudioqt
    coreaddons
    dbusaddons
    i18n
    notifications
    wayland
    windowsystem
    xmlgui
    solid
    config
    network
    service
  ];

  # X11 dependencies
  xorgDeps = with xorg; [
    libX11
    libXext
    libXcursor
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    xcb-util
    xcb-util-image
    xcb-util-keysyms
    xcb-util-renderutil
    xcb-util-wm
  ];

  # All build-time dependencies
  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    extra-cmake-modules
    patchelf
    file
  ] ++ qtDeps ++ kf6Deps ++ xorgDeps ++ [
    libxkbcommon
    wayland
    mesa
    openssl
  ];

  # Runtime dependencies
  propagatedBuildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6-mqtt
    bluez-qt
    pulseaudio-qt
  ] ++ (with kf6; [
    bluezqt
    pulseaudioqt
    coreaddons
    dbusaddons
    i18n
    notifications
    solid
    config
  ]);

  # Make Qt environment variables
  qtPluginPath = lib.makeLibraryPath (
    qtDeps ++ [qt6-mqtt] ++ kf6Deps
  ) + "/plugins";

  qmlImportPath = lib.makeLibraryPath (
    [qt6.qtdeclarative] ++ (with kf6; [kf6declarative])
  ) + "/qml";

  xdgDataDirs = lib.makeLibraryPath (
    kf6Deps ++ [qt6.qtbase]
  ) + "/share";

  # Helper to generate patchelf commands
  fixLibs = lib.concatMapStringsSep "\n" (lib.genAttrs propagatedBuildInputs (lib.getName));

in

stdenv.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = nativeBuildInputs;
  propagatedBuildInputs = propagatedBuildInputs;

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DBUILD_TESTING=OFF"
    "-DKDE_INSTALL_USE_QT_SYSTEM_PATHS=ON"
    "-G Ninja"
  ];

  preConfigure = ''
    export QT_PLUGIN_PATH="${qtPluginPath}"
    export QML2_IMPORT_PATH="${qmlImportPath}"
    export XDG_DATA_DIRS="${xdgDataDirs}"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/kiot/examples
    mkdir -p $out/share/applications
    mkdir -p $out/share/metainfo
    mkdir -p $out/lib/systemd/system

    cmake -B build ${cmakeFlags} ${src}
    ninja -C build

    # Install binary
    cp build/kiot $out/bin/

    # Install examples
    cp -r ${src}/examples/*.conf $out/share/kiot/examples/ 2>/dev/null || true

    # Install systemd service
    cp ${src}/scripts/org.kde.kiot.service $out/lib/systemd/system/ 2>/dev/null || true

    # Install desktop file
    cp ${src}/core/org.kde.kiot.desktop $out/share/applications/ 2>/dev/null || true

    # Install appdata
    cp ${src}/core/org.kde.kiot.appdata.xml $out/share/metainfo/ 2>/dev/null || true

    runHook postInstall
  '';

  fixupPhase = ''
    runHook fixupPhase

    # Fix library paths
    ${fixLibs} | while read -r libname; do
      for needed in $(patchelf --print-needed $out/bin/kiot 2>/dev/null | grep "lib${libname}" | head -1); do
        [ -n "$needed" ] && patchelf --replace-needed "$needed" "${placeholder "out"}/lib/$needed" $out/bin/kiot || true
      done
    done
  '';

  meta = with lib; {
    description = "KDE Internet of Things - Home Assistant integration for KDE Plasma";
    longDescription = ''
      KIOT (KDE Internet Of Things) is a background daemon that exposes useful
      information and actions from your local desktop session to a home
      automation controller like Home Assistant via MQTT.

      Features:
      - Power state monitoring (suspend, resume, shutdown)
      - User activity detection
      - Screen lock state
      - Audio control
      - Battery status
      - Bluetooth device management
      - Custom scripts and shortcuts
      - D-Bus integration for system events
    '';
    homepage = "https://github.com/davidedmundson/kiot";
    license = licenses.asl20;
    maintainers = with maintainers; [ davidedmundson ];
    platforms = platforms.linux;
  };
}
