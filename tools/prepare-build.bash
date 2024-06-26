#!/bin/bash

# prepare build

_config_dir="$CONFIG_DIR"
_tools_dir="$TOOLS_DIR"
_env_dest="$T2_ROOT"

# determine build order
if [[ -e "build_binutils" && -e "build_gcc" && -e "build_glibc" ]]; then

	_build="full"

elif [[ -e "build_binutils" && -e "build_gcc" ]]; then

	_build="binutils-gcc"

elif [[ -e "build_binutils" && -e "build_glibc" ]]; then

	_build="binutils-glibc"

elif [[ -e "build_gcc" && -e "build_glibc" ]]; then

	_build="gcc-glibc"

elif [[ -e "build_binutils" ]]; then

	_build="binutils"

elif [[ -e "build_gcc" ]]; then

	_build="gcc"

elif [[ -e "build_glibc" ]]; then

	_build="glibc"
else
	# exit early
	echo "I: No build needed." 1>&2
	exit 0
fi

# create build commands ("built order") according to configured build order
case ${_build} in

	full)
		_build_order="0-glibc 0-binutils 0-gcc 1-glibc 1-gcc 2-binutils 2-gcc"
		;;

	binutils-gcc)
		_build_order="0-binutils 0-gcc 1-gcc 2-binutils 2-gcc"
		;;

	binutils-glibc)
		_build_order="0-glibc 0-binutils 1-glibc 2-binutils"
		;;

	gcc-glibc)
		_build_order="0-glibc 0-gcc 1-glibc 1-gcc 2-gcc"
		;;

	binutils)
		_build_order="0-binutils 2-binutils"
		;;

	gcc)
		_build_order="0-gcc 1-gcc 2-gcc"
		;;

	glibc)
		_build_order="0-glibc 1-glibc"
		;;
esac

sed -e "s/@@_BUILD_ORDER_@@/${_build_order}/" \
    -e "s/@@_TARGET_CONFIG_@@/$( cat target_config )/" \
    "${_config_dir}/build-order.tpl" > "${_env_dest}/build-order.bash" || exit 1

# place main build script in build environment
cp "${_tools_dir}/perform-build.bash" "${_env_dest}/" || exit 1

# make sure the scripts are executable
chmod +x ${_env_dest}/{perform-build.bash,build-order.bash} || exit 1

# also echo build order for other tools to be able to use it
echo "${_build_order}"

exit
