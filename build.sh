#!/bin/bash

# disable proxy
unset http_proxy
unset no_proxy 
unset https_proxy

# install rpm devtools
cd /home
swupd update --quiet 
swupd bundle-add curl dnf --quiet 

# manage dependencies
shopt -s expand_aliases && alias dnf='dnf --releasever=latest --disableplugin=changelog'
dnf -q config-manager \
    --add-repo https://cdn.download.clearlinux.org/current/x86_64/os \
    --add-repo https://gitlab.com/clearfraction/repository/-/raw/repos
dnf -q -y groupinstall build srpm-build
dnf -q -y builddep *.spec

# build the package
# rpmbuild --quiet  - super useful to cut the logs
# spectool fails some times (needs a hand) --undefine=_disable_source_fetch
rpmbuild --quiet -bb *.spec --define "_topdir $PWD" \
         --define "_sourcedir $PWD" --undefine=_disable_source_fetch \
         --define "debug_package %{nil}" --define "abi_package %{nil}"

# deployment
count=`ls -1 $PWD/RPMS/*/*.rpm 2>/dev/null | wc -l`
if [ $count != 0 ]
then
echo "Start deployment..."
git clone -b repos https://gitlab.com/clearfraction/repository.git /tmp/repository
mv $PWD/RPMS/*/*.rpm /tmp/repository
createrepo_c --database --compatibility /tmp/repository
cd /tmp/repository && git checkout -b repos
# && rm -rf .git && git init
git add .
git -c user.name='GitlabCI' -c user.email='gitlab@gitlab.com' commit -m 'rebuild the repository'
git push -f https://paulcarroty:$GITLAB_API_KEY@gitlab.com/clearfraction/repository.git repos
fi 
