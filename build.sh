#!/bin/bash

# install rpm devtools
cd /home
swupd update
swupd bundle-add package-utils curl
curl -L https://gist.github.com/paulcarroty/ec7133a6d41762e23cdacc75dab69423/raw/9869938ddb4471b177d27de8bffdea7fd4673099/spectool -o /usr/bin/spectool
chmod +x /usr/bin/spectool

# manage dependencies
dnf config-manager --add-repo https://download.clearlinux.org/current/x86_64/os/
dnf -y groupinstall build srpm-build
spectool -g *.spec
dnf -y builddep *.spec

# build the package
rpmbuild -bb *.spec --define "_sourcedir $PWD"

# deployment
echo "start deployment"
count=`ls -1 /rpmbuild/RPMS/*/*.rpm 2>/dev/null | wc -l`
if [ $count != 0 ]
then 
git clone -b repos --depth=1 https://gitlab.com/clearfraction/repository.git /tmp/repository
mv /rpmbuild/RPMS/*/*.rpm /tmp/repository
createrepo_c --database --compatibility /tmp/repository
cd /tmp/repository && rm -rf .git
git add .
git -c user.name='CI' -c user.email='ci@ci.com' commit -m 'rebuild the repositories'
git push -f https://paulcarroty:$GITLAB_API_KEY@gitlab.com/clearfraction/repository.git repos 
fi 
