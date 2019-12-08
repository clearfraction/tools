#!/bin/bash
# install rpm devtools
cd /home
swupd bundle-add package-utils curl
curl -L https://gist.github.com/paulcarroty/ec7133a6d41762e23cdacc75dab69423/raw/9869938ddb4471b177d27de8bffdea7fd4673099/spectool -o /usr/bin/spectool
chmod +x /usr/bin/spectool

# manage dependencies
dnf config-manager --add-repo https://download.clearlinux.org/current/x86_64/os/
dnf -y groupinstall build srpm-build
spectool -g *.spec
dnf builddep *.spec


# build the package
rpmbuild -bb *.spec --define "_sourcedir $PWD"'
 

