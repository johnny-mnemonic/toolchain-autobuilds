#!/bin/bash

# workflow

# Only for local operation
#T2_TEMPLATE_BASE_DIR="$PWD/toolchain-autobuilds/config/t2"
#T2_ROOT="$PWD/t2-minimal"
#CONFIG_DIR="$PWD/toolchain-autobuilds/config"
#TOOLS_DIR="$PWD/toolchain-autobuilds/tools"
#SNAPSHOTS="$PWD/snapshots"
#PAST_BUILDS="$PWD/past-builds"
#
#export T2_TEMPLATE_BASE_DIR T2_ROOT CONFIG_DIR TOOLS_DIR SNAPSHOTS PAST_BUILDS

# prepare snapshots if any new are available
NEW_SNAPSHOTS=0

for _url_file in ${CONFIG_DIR}/*url; do

	_filename=$( basename "$_url_file" )

	_package=${_filename%%-*}

	_snapshot_url=""

	echo -n "I: Trying to find new snapshot for package \`${_package}'... "
	_snapshot_url=$( find-snapshot.bash "$_url_file" )

	if [[ $? -eq 0 ]]; then

		echo "found"

		NEW_SNAPSHOTS=1

		echo -n "I: Now downloading new snapshot from \`"$_snapshot_url"'... "
		# also download new snapshot
		_snapshot_file=$( download-snapshot.bash "$_snapshot_url" ) || exit 1
		echo "OK"

		echo -n "I: Now preparing snapshot: "
		prepare-snapshot.bash "$_snapshot_url" "$_snapshot_file" || exit 1
		echo "OK"
	else
		echo "not found, ignoring package \`${_package}'"
	fi
done

# prepare build environment
if [[ $NEW_SNAPSHOTS -eq 1 ]]; then

	# new snapshot(s) exist(s), make build environment
	echo "I: Now preparing build environment... "
	prepare-env.bash || exit 1
	echo "done"
else
	# exit early
	exit 1
fi

# create build order
echo -n "I: creating build order... "
prepare-build.bash || exit 1
echo "OK"

# perform builds
echo "I: performing build... "
sudo ${TOOLS_DIR}/exec-in-chroot.bash "$T2_ROOT" "/perform-build.bash" || exit 1
echo "OK"

exit
