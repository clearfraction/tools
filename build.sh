#!/bin/bash

# disable proxy
unset http_proxy
unset no_proxy 
unset https_proxy

# install rpm devtools
cd /home
swupd update --quiet 
swupd bundle-add curl dnf mixer --quiet 

# manage dependencies
shopt -s expand_aliases && alias dnf='dnf -q -y --releasever=latest --disableplugin=changelog,needs_restarting'
createrepo_c /home/artifact/
dnf config-manager \
    --add-repo https://cdn.download.clearlinux.org/current/x86_64/os \
    --add-repo file:///home/artifact
dnf groupinstall build srpm-build
dnf builddep *.spec

# building the package
rpmbuild --quiet -bb *.spec --define "_topdir $PWD" \
         --define "_sourcedir $PWD" --undefine=_disable_source_fetch \
         --define "abi_package %{nil}"
# post cleanup
mv RPMS/*/*.rpm RPMS/
