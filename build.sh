#!/bin/bash

clear_proxy() {
unset http_proxy
unset no_proxy 
unset https_proxy
}

#  BEGIN THE PROGRAM

clear_proxy

# install rpm devtools
echo "Check the length of GL env key: "
env | grep -i gitlab | wc -c
cd /home
swupd bundle-add package-utils curl  1>/dev/null

# manage dependencies
alias dnf='dnf --releasever=latest'
dnf config-manager --add-repo https://cdn.download.clearlinux.org/current/x86_64/os/
dnf config-manager --add-repo https://gitlab.com/clearfraction/repository/raw/repos/
dnf -q -y groupinstall build srpm-build
dnf -q -y builddep *.spec

# build the package
# rpmbuild --quiet  - super useful to cut the logs
# spectool fails some times (needs a hand) --undefine=_disable_source_fetch
rpmbuild --quiet -bb *.spec --define "_topdir $PWD" --define "_sourcedir $PWD" --undefine=_disable_source_fetch --define "debug_package %{nil}" --define "abi_package %{nil}"

# deployment
count=`ls -1 $PWD/RPMS/*/*.rpm 2>/dev/null | wc -l`
if [ $count != 0 ]
then
echo "Start deployment..."
git clone -b repos https://:$GITLAB_API_KEY@gitlab.com/clearfraction/repository.git /tmp/repository
mv $PWD/RPMS/*/*.rpm /tmp/repository
createrepo_c --database --compatibility /tmp/repository
cd /tmp/repository && rm -rf .git && git init && git checkout -b repos
git add .
git -c user.name='GitlabCI' -c user.email='gitlab@gitlab.com' commit -m 'rebuild the repositories'
git push -f --set-upstream repos repos
fi 
