# Nix Zephyr SDK

[Nix Flake](https://zero-to-nix.com/concepts/flakes) Collection for [Zephyr SDK](https://docs.zephyrproject.org/latest/develop/toolchains/zephyr_sdk.html) Toolchain

## Description

This repository provides a [Nix Flake](https://zero-to-nix.com/concepts/flakes) collection for the Zephyr SDK toolchain. The [Zephyr SDK](https://docs.zephyrproject.org/latest/develop/toolchains/zephyr_sdk.html) is a collection of tools and libraries for developing applications for the [Zephyr RTOS](https://zephyrproject.org/). This [Nix Flake](https://zero-to-nix.com/concepts/flakes) makes it easy to install and manage the Zephyr SDK toolchain in a reproducible manner across different systems.

## Features

- Easy installation of Zephyr SDK toolchain using Nix.
- Reproducible builds to ensure consistent behavior across different systems.
- Flexible configurations to suit various development environments.
- Ability to pin specific versions of Zephyr SDK.
- Support for multiple platforms including Linux and macOS.

## Prerequisites

- [Nix package manager](https://nixos.org/download.html)
- [Basic knowledge of Zephyr SDK and RTOS development](https://docs.zephyrproject.org/latest/index.html)

## Installation

Firstly, make sure you have [Nix with flakes support enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes). Then you can add this flake as an input to your own flake, or install the tools globally.

### Activating the Flake

To use this flake in your own project:

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    zephyr-sdk.url = "git+https://code.srx.dev/srx/nix-zephyr-sdk";
  };

  outputs = { self, zephyr-sdk, nixpkgs }: {
    devShells.default = zephyr-sdk.devShells.zephyr;
  };
}
```

### Direct Installation

To install the Zephyr SDK globally:

```sh
nix profile install git+https://code.srx.dev/srx/nix-zephyr-sdk
```

## Usage

Once installed, the Zephyr SDK tools should be available in your shell. For example, to build a Zephyr application:

```sh
west build -b <BOARD> <SOURCE_DIRECTORY>
```

Please consult the [Zephyr documentation](https://docs.zephyrproject.org/latest/index.html) for full usage instructions.

## Contributing

Contributions are welcome! Please submit Pull Requests or Issues to help improve the project.

## License

This project follows the [REUSE Specification](https://reuse.software/spec/) and is licensed under the [MIT License - see the LICENSE file](./LICENSES/MIT.txt) for details.
