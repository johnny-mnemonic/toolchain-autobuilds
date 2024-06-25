#!/bin/bash

_program="eic"
_chrootIdentifier="chrooted"


if [[ "$2" != "" ]]; then

	_chrootDir="$1"
	_script="$2"
else
	echo "Usage: ${_program} <CHROOT_DIR> <SCRIPT>"
	exit 64
fi

echo -n "${_program}: Mounting pseudo file systems into chroot environment... "

# mount pseudo file systems
#mount -o bind /proc ${_chrootDir}/proc && \
#mount -o bind /sys ${_chrootDir}/sys && \
#mount -o bind /dev/pts ${_chrootDir}/dev/pts && \
#mount -o bind /run ${_chrootDir}/run
mount -t proc proc ${_chrootDir}/proc && \
mount -t sysfs sysfs ${_chrootDir}/sys && \
mount -t devtmpfs udev ${_chrootDir}/dev && \
mount -t devpts devpts ${_chrootDir}/dev/pts && \
mount -t tmpfs tmpfs ${_chrootDir}/tmp

if [[ $? -ne 0 ]]; then

	echo -e "\n${_program}: Errors during mount operations. Exiting."
	exit 1
else
	echo "OK"
fi

echo "${_program}: Entering chroot environment..."

# On Debian the PS1 is '${debian_chroot:+($debian_chroot)}\u@\h:\w\$', so setting "debian_chroot" will prefix the prompt when inside of a changed root environment.
#debian_chroot="${_chrootIdentifier}" chroot $1
chroot $1 env -i "$_script"

echo "${_program}: Exited chroot environment."

echo -n "${_program}: Unmounting pseudo file systems... "

# unmount pseudo file systems
umount ${_chrootDir}/tmp \
       ${_chrootDir}/dev/pts

if ! umount ${_chrootDir}/dev; then

	sleep 5
	umount ${_chrootDir}/dev
fi

umount ${_chrootDir}/sys \
       ${_chrootDir}/proc

if [[ $? -ne 0 ]]; then

        echo -e "\n${_program}: Errors during umount operations. Exiting."
        exit 1
else
        echo "OK"
fi

exit
