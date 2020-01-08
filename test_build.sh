#!/bin/bash

# install rpm devtools
pushd /home
swupd update  1>/dev/null
swupd bundle-add package-utils curl  1>/dev/null
curl -L https://gist.github.com/paulcarroty/ec7133a6d41762e23cdacc75dab69423/raw/9869938ddb4471b177d27de8bffdea7fd4673099/spectool -o /usr/bin/spectool
chmod +x /usr/bin/spectool

# manage dependencies
dnf config-manager --add-repo https://download.clearlinux.org/current/x86_64/os/
dnf config-manager --add-repo https://gitlab.com/clearfraction/repository/raw/repos/
dnf -q -y groupinstall build srpm-build
spectool -g *.spec
dnf -q -y builddep *.spec

# build the package
# rpmbuild --quiet  - super useful to cut the logs
rpmbuild -bb *.spec --define "_topdir $PWD" --define "_sourcedir $PWD"

# Test install
pushd $PWD/RPMS
dnf install *.rpm
popd
