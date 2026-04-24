{
  autoPatchelfHook,
  gmp,
  gnutls,
  hidapi,
  libftdi1,
  libusb,
  libxml2,
  pixman,
  python38,
  readline,
  cmake,
  dtc,
  fetchurl,
  file,
  findutils,
  glib,
  glibcLocales,
  lib,
  libfaketime,
  nettle,
  python3,
  stdenv,
  unzip,
  which,
  xz,
  toolchain_provider ? "gnu",
  ...
}: let
  hosttools.version = "0.10";
in
  stdenv.mkDerivation rec {
    pname = "zephyr-sdk";
    version = "1.0.1";

    src = let
      getHash = toolchain: arch:
        {
          gnu = {
            "linux-x86_64" = "sha256-N6jFtVacK0gtOQmcZf492sTkNSSZbHMZB+Hp9YGMu6c=";
            "linux-aarch64" = "sha256-bjgBj3CvXpDBjMBML4rFqRyZ9VWbJWktGw3jKMPtuIo=";
            "macos-aarch64" = "sha256-PcY0aliI67zuGYAb9icWJ/BIGXeP4O88fzx1KOj07yo=";
          };
          llvm = {
            "linux-x86_64" = "sha256-E7liMMkAJRBeyb3JFLHMtsSzGfaKRFGOxOhu8pPz3Og=";
            "linux-aarch64" = "sha256-6mGi90iEbAmxpOO3CPbce5ehTI0zVSPC0EpRMzfqDP8=";
            "macos-aarch64" = "sha256-tN7xZieGSSXTWXHWEerT7+iAiQ+KjR9XMkRKl31Y/5o=";
          };
        }.${toolchain}.${arch};
      getArch =
        {
          "x86_64-linux" = "linux-x86_64";
          "aarch64-linux" = "linux-aarch64";
          "aarch64-darwin" = "macos-aarch64";
        }
        .${stdenv.system}
        or (throw "${pname}-${version}: ${stdenv.system} is unsupported.");
      getUrl = arch: "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/${pname}-${version}_${arch}_${toolchain_provider}.tar.xz";
    in
      fetchurl {
        url = getUrl getArch;
        sha256 = getHash toolchain_provider getArch;
      };

    nativeBuildInputs = [
      autoPatchelfHook
      glib
      glibcLocales
      libfaketime
      python3.pythonForBuild
      unzip
      which
      xz
      file
      findutils
    ];

    buildInputs = [
      cmake
      dtc
      gmp
      gnutls
      hidapi
      libftdi1
      libusb
      libxml2
      nettle
      pixman
      python3
      readline
    ];

    postUnpack = ''
      $sourceRoot/hosttools/zephyr-sdk-$(uname -m)-hosttools-standalone-${hosttools.version}.sh \
      			-y -p -d $sourceRoot

      rm -f $sourceRoot/{setup,zephyr-sdk-$(uname -m)-hosttools-standalone-*}.sh \
      			$sourceRoot/{version,environment-setup}-$(uname -m)-pokysdk-linux
    '';

    patchPhase = ''
      patchShebangs .

      substituteInPlace cmake/zephyr/host-tools.cmake \
        --replace "/usr/share" "/share"								\
        --replace "/sysroots/\*-pokysdk-linux" ""

      sed '/SYSROOT_DIR/d' cmake/zephyr/*/target.cmake
      sed '/CROSS_COMPILE/d' cmake/zephyr/*/target.cmake

    '';

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{share,lib}

      find ./sysroots/$(uname -m)-pokysdk-linux/usr/bin -type l -exec unlink {} \;

      mv ./sysroots/$(uname -m)-pokysdk-linux/usr/{bin,libexec,share} $out/
      mv ./sysroots/$(uname -m)-pokysdk-linux/usr/synopsys/bin/qemu-system-* $out/bin/
      mv ./sysroots/$(uname -m)-pokysdk-linux/usr/xilinx/bin/qemu-system-aarch64 \
      		$out/bin/qemu-system-xilinx-aarch64
      mv ./sysroots/$(uname -m)-pokysdk-linux/usr/xilinx/bin/qemu-system-microblazeel \
      		$out/bin/qemu-system-xilinx-microblazeel

      mv ./cmake $out
      mv ./*zephyr* $out
      mv ./sdk_* $out

      runHook postInstall
    '';

    setupHook = ./setup-hook.sh;

    meta = with lib; {
      description = "Zephyr SDK (Toolchains, Development Tools)";
      homepage = "https://github.com/zephyrproject-rtos/sdk-ng/";
      license = licenses.asl20;
      platforms = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    };
  }
