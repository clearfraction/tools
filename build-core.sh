#!/bin/bash
# identical to build.sh without Clear Fraction repositories

# disable proxy
unset http_proxy
unset no_proxy 
unset https_proxy

# install rpm devtools
cd /home
swupd update --quiet 
swupd bundle-add curl dnf --quiet 

# manage dependencies
shopt -s expand_aliases && alias dnf='dnf -q -y --releasever=latest --disableplugin=changelog'
dnf config-manager --add-repo https://cdn.download.clearlinux.org/current/x86_64/os
dnf groupinstall build srpm-build && dnf install createrepo_c
dnf builddep *.spec

# build the package
# rpmbuild --quiet  - super useful to cut the logs
# spectool fails some times (needs a hand) `--undefine=_disable_source_fetch`
rpmbuild --quiet -bb *.spec --define "_topdir $PWD" \
         --define "_sourcedir $PWD" --undefine=_disable_source_fetch \
         --define "abi_package %{nil}"

# deployment
count=`ls -1 $PWD/RPMS/*/*.rpm 2>/dev/null | wc -l`
if [ $count != 0 ]
then
echo "Start deployment..."
git clone -b repos https://gitlab.com/clearfraction/repository.git /tmp/repository
mv $PWD/RPMS/*/*.rpm /tmp/repository
createrepo_c --database --compatibility /tmp/repository
cd /tmp/repository && rm -rf *debuginfo*
git add .
git -c user.name='GitlabCI' -c user.email='CI@gitlab.com' commit -m 'rebuild the repository'
git push -f https://paulcarroty:$GITLAB_API_KEY@gitlab.com/clearfraction/repository.git repos
fi 
