# Scrips Description

## Installation Scripts Files

* __setup-system-jazzy-noble.sh__ installs the ROS2 Jazzy development environment [Install Ubuntu (deb packages)](https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html)
* __setup-ctrlx-datalayer-deb.sh__ installs the ctrlx-datalayer Debian package and registers its storage directory as local package source
* __install-ctrlx-datalayer-deb.sh__ installs the ctrlx-datalayer Debian package, see [ctrlX AUTOMATION SDK/Releases](https://github.com/boschrexroth/ctrlx-automation-sdk/releases)

``` bash
# install default debian package
./setup-ctrlx-datalayer-deb.sh 
```

``` bash
# install from SDK version 4.4.0 debian package version 3.4.1
./install-ctrlx-datalayer-deb.sh 4.4.0 3.4.1
```

## Build Scripts Files

* __colcon-build.sh__ helper script for colon build, base on ROS2 __Jazzy__
* __build-snap-cpp.sh__ helper script for creating snaps based on c++ projects
* __build-snap-py.sh__ Help script for creating snaps based on python projects

The base snap has its own build scripts next to its `snapcraft.yaml`, see
[ros2-base-jazzy-deb/README.md](../ros2-base-jazzy-deb/README.md):

* __../ros2-base-jazzy-deb/build-overlay-packages.sh__ builds the overlay packages listed in `overlay.repos` that the base snap dumps into `opt/ros/jazzy`
* __../ros2-base-jazzy-deb/build-snap-amd64.sh__ packs the base snap for amd64
* __../ros2-base-jazzy-deb/build-snap-arm64.sh__ packs the base snap for arm64 (native arm64 host required)

SPDX-License-Identifier: MIT
