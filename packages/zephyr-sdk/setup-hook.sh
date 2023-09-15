addZephyrSDKCEnvVars() {
	export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
	export ZEPHYR_SDK_INSTALL_DIR=@out@
	export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:@out@/lib/cmake/
}

addEnvHooks "$hostOffset" addZephyrSDKCEnvVars
