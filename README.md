# tools

## Building
`*build.sh` - scripts for [automating](https://github.com/clearfraction/ffmpeg/blob/master/.travis.yml) building process

* `scratch-build.sh` - deploy packages to testing/experimental [repository](https://gitlab.com/clearfraction/scratch-repository)
* `build.sh` - deploy packages to stable [repository](https://gitlab.com/clearfraction/repository), highly recommend to use if package is 100% working
* `test_build.sh` - alternative version for test/build, in development stage.

Travis configs (`.travis.yml`) are *universal* for all projects.

* build for general repository:

```yml
os: linux
language: generic
services:
  - docker
script:
  - curl -LO https://raw.githubusercontent.com/clearfraction/tools/master/build.sh && chmod +x build.sh
  - docker run --privileged --cap-add=SYS_ADMIN -e GITLAB_API_KEY=$GITLAB_API_KEY -v $(pwd):/home clearlinux:latest sh -c "cd /home && ./build.sh"
```

* build for scratch repository: 

```yml
os: linux
language: generic
services:
  - docker
script:
  - curl -LO https://raw.githubusercontent.com/clearfraction/tools/master/scratch-build.sh && chmod +x scratch-build.sh
  - docker run --privileged --cap-add=SYS_ADMIN -e GITLAB_API_KEY=$GITLAB_API_KEY -v $(pwd):/home clearlinux:latest sh -c "cd /home && ./scratch-build.sh"
```

Fast switch from scratch to general repository: `sed -i  's/scratch-//g' .travis.yml` 
