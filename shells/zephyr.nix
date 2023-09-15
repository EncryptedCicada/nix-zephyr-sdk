{self, ...}: system:
with self.pkgs.${system};
with self.packages.${system};
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
      (python310.withPackages (ps:
        with ps; [
          west
          pyelftools
        ]))
      zephyr-sdk

      # ESP
      espup
      esptool
    ];
  }
