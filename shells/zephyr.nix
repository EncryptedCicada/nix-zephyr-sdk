{self, ...}: system: zephyrSdk:
with self.pkgs.${system};
  mkShell {
    name = "zephyr-dev";
    buildInputs = [
      # C/CPP
      bear
      bison
      ccache
      clang
      clang-tools
      clangStdenv
      cmake
      cmake-format
      cmake-language-server
      dfu-util
      flex
      gdb
      gnumake
      gperf
      gtest
      libffi
      libusb
      ncurses
      ninja

      # Zephyr
      (python3.withPackages (ps:
        with ps; [
          west
          pyelftools
        ]))
      zephyrSdk

      # ESP
      espup
      esptool
    ];
  }
