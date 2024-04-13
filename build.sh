#!/bin/bash

# disable proxy
unset http_proxy
unset no_proxy 
unset https_proxy

# install rpm devtools
cd /home
swupd update --quiet --retry-delay=1
swupd bundle-add curl dnf mixer --quiet 

# manage dependencies
echo -e "[main]\nmax_parallel_downloads=20\nretries=30\nfastestmirror=True" >> /etc/dnf/dnf.conf
shopt -s expand_aliases && alias dnf='dnf -q -y --releasever=latest --disableplugin=changelog,needs_restarting'
createrepo_c -q /home/artifact/
dnf config-manager --add-repo https://cdn.download.clearlinux.org/current/x86_64/os  --add-repo https://download.clearlinux.org/current/x86_64/os --add-repo file:///home/artifact
# --add-repo https://cdn-alt.download.clearlinux.org/current/x86_64/os
dnf groupinstall build srpm-build
dnf builddep *.spec || { echo "Failed to handle build dependencies"; exit 1; }

# building the package
echo 'exit 0' > /usr/lib/rpm/clr/brp-create-abi
# rpmbuild --quiet
rpmbuild -bb *.spec --define "_topdir $PWD" \
         --define "_sourcedir $PWD" --undefine=_disable_source_fetch \
         --define "abi_package %{nil}" || { echo "Build failed"; exit 1; }
# post cleanup
mv RPMS/*/*.rpm RPMS/
