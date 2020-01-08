#!/bin/bash

readargs() {
  while [ "$#" -gt 0 ] ; do
    case "$1" in
       -n)
        if [ "$2" ] ; then
          namegit="$2"
          shift ; shift
        else
          echo "Missing a value for $1."
          echo
          shift
          usage
exit
        fi
      ;;
      *)
        echo "Unknown option or argument $1. Use -n namerepository"
        echo
        shift
        usage
      exit 1
      ;;
    esac
  done
}

#  BEGIN THE PROGRAM
readargs "$@"

# install rpm devtools
pushd /home
swupd update  1>/dev/null
swupd bundle-add package-utils curl git 1>/dev/null
curl -L https://gist.github.com/paulcarroty/ec7133a6d41762e23cdacc75dab69423/raw/9869938ddb4471b177d27de8bffdea7fd4673099/spectool -o /usr/bin/spectool
chmod +x /usr/bin/spectool
# manage dependencies
dnf config-manager --add-repo https://download.clearlinux.org/current/x86_64/os/
dnf config-manager --add-repo https://gitlab.com/clearfraction/repository/raw/repos/
dnf -q -y groupinstall build srpm-build
# Cloning repository
rm -rf ${namegit} && git clone https://github.com/clearfraction/${namegit}.git && pushd ${namegit}
# Downloading sources
spectool -g *.spec
# Installing build dependencies
dnf -q -y builddep *.spec
# build the package
# rpmbuild --quiet  - super useful to cut the logs
rpmbuild -bb *.spec --define "_topdir $PWD" --define "_sourcedir $PWD"

# Test install
pushd $PWD/RPMS
dnf -y install *.rpm
popd
 popd