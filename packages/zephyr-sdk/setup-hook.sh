addZephyrSDKCEnvVars() {
	cmakeFlagsArray+=(-DCMAKE_MODULE_PATH=@out@/lib/cmake)
	cmakeFlagsArray+=(-DZEPHYR_TOOLCHAIN_VARIANT=zephyr)
	cmakeFlagsArray+=(-DZEPHYR_SDK_INSTALL_DIR=@out@)
	cmakeFlagsArray+=(-DHOST_TOOLS_HOME=@out@)

	export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
	export ZEPHYR_SDK_INSTALL_DIR=@out@
	export HOST_TOOLS_HOME=@out@
}

addEnvHooks "$hostOffset" addZephyrSDKCEnvVars
