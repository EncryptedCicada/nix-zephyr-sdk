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
  ...
}: let
  hosttools.version = "0.9";
in
  stdenv.mkDerivation rec {
    pname = "zephyr-sdk";
    version = "0.16.1";

    src = let
      getHash = arch:
        {
          "linux-x86_64" = "sha256-UTONUapM6iUWZBzg2dwLUbdjd58A3EVkorwN1xPfIsc=";
          "linux-aarch64" = "sha256-BiuytcR8pW3Sm3+S3X8Hpc4iulE3WdK2lgvGWFMesAw=";
          "macos-x86_64" = "sha256-sEbHviuQ7qMPH9kHr+DwgCFnAw62NWCxKfJj2aV1Tdo=";
          "macos-aarch64" = "sha256-Vf/Gtzdv21x7+20zyEYEnmwPitYmL4ZClPxC1AWbGiY=";
        }
        .${arch};
      getArch =
        {
          "x86_64-linux" = "linux-x86_64";
          "aarch64-linux" = "linux-aarch64";
          "x86_64-darwin" = "macos-x86_64";
          "aarch64-darwin" = "macos-aarch64";
        }
        .${stdenv.system}
        or (throw "${pname}-${version}: ${stdenv.system} is unsupported.");
      getUrl = arch: "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/${pname}-${version}_${arch}.tar.xz";
    in
      fetchurl {
        url = getUrl getArch;
        sha256 = getHash getArch;
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
      python38
      readline
    ];

    postUnpack = ''
      $sourceRoot/zephyr-sdk-$(uname -m)-hosttools-standalone-${hosttools.version}.sh \
      			-y -p -d $sourceRoot

      rm -f $sourceRoot/{setup,zephyr-sdk-$(uname -m)-hosttools-standalone-*}.sh \
      			$sourceRoot/{version,environment-setup}-$(uname -m)-pokysdk-linux
    '';

    patchPhase = ''
      patchShebangs .

      substituteInPlace cmake/zephyr/host-tools.cmake \
      	--replace "/usr/share" "/share"								\
      	--replace "/sysroots/\*-pokysdk-linux" ""
    '';

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{share,lib}

      # remove deprecated symbolic links
      find ./sysroots/$(uname -m)-pokysdk-linux/usr/bin -type l -exec unlink {} \;

      # add zephyr-sdk standalone hosttools
      mv ./sysroots/$(uname -m)-pokysdk-linux/usr/{bin,libexec,share} $out/
      mv ./sysroots/$(uname -m)-pokysdk-linux/usr/synopsys/bin/qemu-system-* $out/bin/
      mv ./sysroots/$(uname -m)-pokysdk-linux/usr/xilinx/bin/qemu-system-aarch64 \
      		$out/bin/qemu-system-xilinx-aarch64
      mv ./sysroots/$(uname -m)-pokysdk-linux/usr/xilinx/bin/qemu-system-microblazeel \
      		$out/bin/qemu-system-xilinx-microblazeel

      # add zephyr-sdk cmake modules
      mv ./cmake $out/lib/cmake
      mv ./sdk_* $out/lib

      # add zephyr-sdk cross compilers
      mv ./*zephyr*/bin/* $out/bin/

      runHook postInstall
    '';

    setupHook = ./setup-hook.sh;

    meta = with lib; {
      description = "Zephyr SDK (Toolchains, Development Tools)";
      homepage = "https://github.com/zephyrproject-rtos/sdk-ng/";
      license = licenses.asl20;
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    };
  }
