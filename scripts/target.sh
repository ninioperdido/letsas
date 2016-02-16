#!/bin/sh
#    LeTSAS Minimal target creator
#    This program make a DEST directory with the contents needed to run 
#    a minimal distribution of LeTSAS (funtoo / metro derived).
#
#    Copyright (C) 2013 Gerardo Puerta Cardelles <gerardo.puerta@juntadeandalucia.es>
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

## General Variables
N=$'\x1b[0;0m'
B=$'\x1b[0;01m'
R=$'\x1b[31;01m'
G=$'\x1b[00;32m'
B=$'\x1b[34;01m'


## Config variables
CBUILD="i486-pc-linux-gnu"
ABUILD="armv7a-hardfloat-linux-gnueabi"
BOOT="../bootenv"
KERNEL="/usr/src/linux/"
SYSROOT_SYSTEM="../conf/system_world"
BRANCH=`git branch | grep ^\* | awk '{printf $2}'`
TARGET=""
EMERGE=""
KERNEL_DIR=""
LOG=""
COLLECTD_PLUGINS="snmp"
SLIM_THEME="../media/slim"
ICONS="../media/icons"
HTTPD="../conf/httpd"
LPD_FILTER="../conf/ifhp"
UPDATER="./updater.sh"
STRIP="1"
AUTH_KEYS="../conf/authorized_keys"
CONF="../conf/"
EXTRA="../extra/"
ONLY_BASE=0

## Check for superuser access
if [ "$UID" -ne  0 ]
then
        echo "Error! You are not a superuser."
        exit 1
fi

## Argument proccesing
while getopts ":t:e:b:l:k:c:w:i:s:daf" optname
  do
    case "$optname" in
      "t")
        TARGET="$OPTARG"
        ;;
      "e")
        EMERGE="$OPTARG"
        ;;
      "b")
        KERNEL_CONFIG="$OPTARG"
        ;;
      "l")
        LOG="$OPTARG"
        ;;
      "C")
        CBUILD="$OPTARG"
        ;;
      "b")
        BOOT_PACKAGE="$OPTARG"
        ;;
      "w")
        DIST_PACKAGES="$OPTARG"
        ;;
      "d")
        echo -n "I am going to remove existing TARGET, are you sure? (${G}Y${N}/${R}N${N})? "
        read DELETE
	    ;;
      "s")
        STRIP="$OPTARG"
        ;;
      "a")
        CBUILD="armv7a-hardfloat-linux-gnueabi"
        ;;
      "i")
        ONLY_BASE=1
        ;;
      "f")
        DELETE="Y"
        ;;
       "a")
        CBUILD=$ABUILD
        echo "Using ARM arch $ABUILD"
        ;;
      "?")
        echo "Unknown option $OPTARG"
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        ;;
    esac
done

# Set default target
PORTAGE_CONFIGROOT="../crossdev/${CBUILD}"
if [ "$TARGET" == "" ]
then
  TARGET="../builds/${BRANCH}/${CBUILD}_`date +%F`"
fi
PWD=`readlink -f ${TARGET}`

if [ "${LOG}" != "" ]
then
	# Close STDOUT file descriptor
	exec 1<&-
	# Close STDERR FD
	exec 2<&-
	# Open STDOUT as $LOG_FILE file for read and write.
	exec 1>>$LOG
	# Redirect STDERR to STDOUT
	exec 2>&1
fi

# Remove existing target
if [ "${DELETE}" == "Y" ] || [ "${DELETE}" == "y" ]
then
  rm -rf ${TARGET}
fi

if [ ! -d ${TARGET} ]
then
  echo "Creating target directories"
  mkdir -p "${TARGET}"/{bin,boot,dev,proc,sys,usr,root,home,lib,tmp}
  mkdir -p "${TARGET}"/usr/{local,lib,src}
  mkdir -p "${TARGET}"/usr/local/lib
  mkdir -p "${TARGET}"/var/{lock,log,run,www}
  mkdir -p "${TARGET}"/etc/init.d
  ln -s "${KERNEL}" "${TARGET}/usr/src/linux"
  KERNEL_DIR="${TARGET}/usr/src/linux"
  chmod 777 ${TARGET}/tmp
  
  echo "Exporting needed variables"
  export PORTAGE_CONFIGROOT=$PORTAGE_CONFIGROOT
  export KERNEL_DIR="${KERNEL_DIR}" \
  export ROOT="${TARGET}"
  cp -rp ${PORTAGE_CONFIGROOT} ${ROOT}

  echo "Adding needed kernel goodies"
  if [ ! -f /usr/src/linux/Makefile ]; then
    wget -O /usr/src/linux/Makefile https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/plain/Makefile
  fi
 
  echo "Touching /etc/fstab ..."
  touch ${TARGET}/etc/fstab >& /dev/null
  
  echo "Writting /etc/mtab ..."
  cat << END > ${TARGET}/etc/mtab
rootfs / rootfs 0 0
END

  echo "Touching /etc/resolv.conf ..."
  touch ${TARGET}/etc/resolv.conf

  echo "Setting boot environment ..."
  cp -rp ${BOOT}/* ${TARGET}/

  echo "Setting Glibc timezone info ..."
  cp /usr/share/zoneinfo/Europe/Madrid ${TARGET}/etc/localtime
  echo "Europe/Madrid" > ${TARGET}/etc/timezone

  echo "Emerging base system ..."
  emerge --info
  USE="-X gtk" \
  emerge -uvDNt --quiet-build=y --usepkg --with-bdeps=y --binpkg-respect-use=y @letsas_base

  echo "Avoiding busybox overwrite by hosts script ..."
  rm -f ${TARGET}/bin/hostname
  echo "Changing baselayout passwd to ash shell ..."
  sed -ie 's/\/bin\/bash/\/bin\/ash/' ${TARGET}/etc/passwd
  echo "Setting ash shell as valid shell ..."
  echo "/bin/ash" >> ${TARGET}/etc/shells

  echo "Copying libgcc ..."
  GCC_LIBDIR=$(gcc -print-libgcc-file-name)
  GCC_LIBDIR=$(dirname "${GCC_LIBDIR}")
  cp -aL "${GCC_LIBDIR}/libgcc_s.so.1" "${TARGET}/usr/lib"
  cp -aL "${GCC_LIBDIR}/libstdc++.so" "${TARGET}/usr/lib"
 
  echo "Copying /dev/urandom ..."
  cp -a /dev/urandom "${TARGET}/dev/urandom"
  echo "Generating RSA host key ..."
  mkdir ${TARGET}/etc/dropbear
  chroot "${TARGET}" /bin/ash -c "/usr/bin/dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key"
  echo "Generating DSS host key ..."
  chroot "${TARGET}" /bin/ash -c "/usr/bin/dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key"
  echo "Deleting /dev/urandom ..."
  rm "${TARGET}/dev/urandom"
  echo "Setting SETUID to busybox ..."
  chmod a+s ${TARGET}/bin/busybox

  if [ ${ONLY_BASE} -ne 1 ]
  then
    echo "Emerging world packages ..."
    emerge -uvDNt --with-bdeps=y --usepkg --binpkg-respect-use=y --quiet-build=y @letsas
  fi

  echo "Setting authorized keys for root ..."
  mkdir -p ${TARGET}/root/.ssh/
  cp ${AUTH_KEYS} ${TARGET}/root/.ssh/authorized_keys

  if [ ${ONLY_BASE} -ne 1 ]
  then
    echo "Installing extra packages ..."
    (
    for f in "${EXTRA}"/*; do
        echo " * $f"
        tar xf ${f} -C "${TARGET}"/
    done
    )
  fi
  
  echo "Installing slim theme ..."
  mkdir -p ${TARGET}/usr/share/slim/themes/default
  cp -rp ${SLIM_THEME}/*.png ${TARGET}/usr/share/slim/themes/default/
  cp -rp ${SLIM_THEME}/*.theme ${TARGET}/usr/share/slim/themes/default/

  if [ ${ONLY_BASE} -ne 1 ]
  then
    echo "Installing icon theme ..."
    cp -rp ${ICONS}/* ${TARGET}/usr/share/icons/
  
    echo "Setting locales ..."
    echo "es_ES UTF-8" >> ${TARGET}/etc/locale.gen
    echo "Generating locales"
    locale-gen -d ${TARGET}/ -c ${TARGET}/etc/locale.gen
   
    echo "Setting build latest link ..."
    pushd ../builds/${BRANCH}/
    ln -sfn ${CBUILD}_`date +%F` latest
    popd

    echo "Copying script to target ..."
    sed -n '/#######/,$p' "${0}" | sed -n '/bin\/ash/,$p' > "${TARGET}/usr/local/${0#./}"
    chmod 700 "${TARGET}/usr/local/${0#./}"
  fi
  echo "Copying configuration ..."
  cp -rp ${CONF}/{bin,etc,lib,var,usr,sbin,opt} ${TARGET}/

  if [ ${ONLY_BASE} -ne 1 ]
  then
    echo "Entering target ..."
    chroot ${TARGET} /usr/local/${0#./}

    echo "Back from target ..."
  fi
fi

if [ "$EMERGE" != "" ]
then
    if [ $? == 0 ] 
    then
      echo "Emerging packages in TARGET ..."
      PORTAGE_CONFIGROOT="${PORTAGE_CONFIGROOT}" \
      KERNEL_DIR="${KERNEL_DIR}" \
      ROOT="${TARGET}"  \
      emerge -uvDNt --with-bdeps=y --usepkg --binpkg-respect-use=y $EMERGE
    fi
fi

if [ "$STRIP" = "1" ]
then
      echo "Removing unneeded files ..."
      rm -rf ${TARGET}/usr/share/zoneinfo/* ${TARGET}/usr/share/doc ${TARGET}/usr/share/info ${TARGET}/usr/share/man ${TARGET}/usr/share/dict ${TARGET}/usr/include/* ${TARGET}/tmp/* ${TARGET}/var/tmp/* ${TARGET}/var/db/* ${TARGET}/var/lib/misc
      find ${TARGET}/usr/share/i18n/locales/ | grep -v en_US | grep -v es_ES | xargs rm -rf
      find ${TARGET}/usr/share/i18n/charmaps/ | grep -v ISO- | grep -v UTF | xargs rm -rf
      find ${TARGET}/usr/lib/gconv | grep -v ISO | grep -v UTF | grep -v lib | grep -v gconv | xargs rm -rf
      rm -rf ${TARGET}/usr/share/misc/*
      rm -rf ${TARGET}/usr/share/gtk-doc
      rm -rf ${TARGET}/opt/Citrix/ICAClient/nls/{ja,de}
      rm -rf ${TARGET}/var/cache/edb/*
      rm -rf ${TARGET}/usr/share/fc-lang/*
      rm -rf ${TARGET}/var/lib/gentoo
      #rm -rf ${TARGET}/usr/share/mime/*
      mkdir -p ${TARGET}/usr/share/mime/packages
      rm -rf ${TARGET}/usr/share/X11/locale/{pt,el}*
      rm -rf ${TARGET}/usr/share/X11/xkb/symbols/{sun,nokia,macintosh}*
fi

exit

############################ Do not modify the content of this and the following line! ############################
#!/bin/ash

CBUILD="${CBUILD}"

echo "Setting gtk / pango stuff ..."
mkdir -p /etc/pango/${CBUILD}/
mkdir -p /usr/lib/gdk-pixbuf-2.0/2.10.0/
ldconfig
pango-querymodules > /etc/pango/pango.modules
gtk-query-immodules-2.0 --update-cache
update-mime-database /usr/share/mime
gdk-pixbuf-query-loaders > /usr/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
gdk-pixbuf-query-loaders --update-cache

echo "Touching dummy cmdline for updating ..."
mkdir -p /var/tmp/
touch /var/tmp/cmdline

echo "Setting dropbear links ..."
ln -s /usr/bin/dropbearmulti /usr/bin/ssh
ln -s /usr/bin/dropbearmulti /usr/bin/scp

echo "Linking run directories ..."
rm -rf /run
ln -s /var/run /run

echo "Setting hotplug firmware loader ..."
ln -s /sbin/mdev /sbin/hotplug

echo "Setting /etc/mtab ..."
ln -sfn /proc/self/mounts /etc/mtab

echo "Linking libstdc++ ..."
ln -sf /usr/lib/libstdc++.so /usr/lib/libstdc++.so.6
ln -sf /usr/lib/libstdc++.so /usr/lib/libstdc++.so.6.0.17

echo "Fixing libicu links ..."
for f in /usr/lib/*icu*55; do ln -s $f ${f%.*}.53; done

echo "Fixing nslcd.conf permisssions ..."
chmod 600 /etc/nslcd.conf

echo "Setting root home ..."
rsync -a /etc/skel/ /root/

exit 0

