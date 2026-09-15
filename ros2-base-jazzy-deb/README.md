# ROS 2 Jazzy on ctrlX OS: A Snap Implementation of the ROS 2 Jazzy Distribution using ROS 2 Debian Package

## Introduction

We recommend for ROS 2 applications running on a ctrlX OS this approach:

* Build and install a __base snap__ containing the ROS 2 runtime and the components used for the ctrlX Data Layer access.
* This base snap provides its components using the snap [content interface](https://snapcraft.io/docs/content-interface).
* Pack your ROS 2 application into one or more overlay snaps.
* Let these overlay snap use the ROS 2 runtime and the ctrlX Data Layer via the content interface of the __base snap__.

This documentation describes how the base snap `ros2-base` can be build.

!!! important
    The arm64 build needs a native arm64 host, there is no cross-compilation.
    CI builds it on a GitHub `ubuntu-24.04-arm` runner.

## Content of the Base Snap

The file `snap/snapcraft.yaml` defines how the base snap will be build.

### Debian Packages

The snapcraft plugin [colcon](https://snapcraft.io/docs/colcon-plugin) is used to download Debian packages:

* Needed during build process: make, gcc, g++
* Needed at runtime: software-properties-common, ros-jazzy-ros-base, python3-argcomplete, ca-certificates, ctrlx-datalayer

### Python Wheels

The snapcraft plugin [python](https://snapcraft.io/docs/python-plugin) is used to download python wheels:

* ctrlx-datalayer
* empy
* numpy
* rosdep
* rosdistro
* colcon-core
* lark rosdep
* rosdistro
* colcon-core
* lark

### Content Interface

The base snap makes its files available via the content interface `executables`.

## Building the Base Snap

### Prerequisites

The snap is packed in snapcraft __host__ build mode, so the build host itself has
to be an Ubuntu 24.04 (noble) machine with the following in place:

1. ROS 2 Jazzy and the ROS development tools:

        ../scripts/setup-system-jazzy-noble.sh

2. snapcraft 8.x:

        ../scripts/install-snapcraft.sh

3. The ctrlX Data Layer Debian packages registered as a local apt source. The
   `datalayer` part stages `ctrlx-datalayer` from the host's apt sources:

        ../scripts/setup-ctrlx-datalayer-deb.sh 4.6.0

### Overlay Packages

The `b-robotized-overlay-packages` part is sourced from
`./b_robotized_overlay_install`. That directory is __generated and not part of
this repository__, so it has to be built before packing:

        ./build-overlay-packages.sh

The sources are listed in [`overlay.repos`](overlay.repos) and imported with
[vcstool](https://github.com/dirk-thomas/vcstool):

| Repository | Branch | Packages taken into the snap |
| ---------- | ------ | ---------------------------- |
| [ros-controls/foreman](https://github.com/ros-controls/foreman) | `master` | `foreman_msgs` |
| [b-robotized-forks/franka_ros2](https://github.com/b-robotized-forks/franka_ros2) | `b-controlled-box/jazzy` | `franka_msgs` |

Only the packages named in `OVERLAY_PACKAGES` and their workspace dependencies
are built. The imported repositories contain many more packages - hardware
drivers, simulation, MoveIt configs - which are neither built nor have their
dependencies resolved, since several of them are not resolvable through rosdep.

The colcon workspace is created in `.overlay-ws/` at the repository root,
deliberately outside this directory: the `ros-base` part uses `source: ./` with
the colcon plugin, so a `src/` directory here would be built a second time inside
the snap.

To make a release reproducible, pin `version:` in `overlay.repos` to a commit SHA
rather than a branch. `OVERLAY_REPOS_FILE` and `OVERLAY_PACKAGES` override the
defaults:

        OVERLAY_PACKAGES="foreman_msgs" ./build-overlay-packages.sh

### AMD64

Compiling for AMD64 on an AMD64 machine is straight-forward. With the prerequisites and the overlay packages above in place, nothing beyond the `snap/snapcraft.yaml` file and a shell script that calls snapcraft is needed here.

Call:

        ./build-snap-amd64.sh

### ARM64

A native ARM64 build host is required, there is no cross-compilation. Use
corresponding hardware, for example __Raspberry Pi__, a virtual environment such
as __Qemu__ ([installation scripts](https://github.com/boschrexroth/ctrlx-automation-sdk/tree/main/scripts/environment)),
or a GitHub `ubuntu-24.04-arm` runner as the CI does.

Call:

        ./build-snap-arm64.sh

## Continuous Integration

`.github/workflows/build-snap-ros2-base.yml` performs exactly the steps above on
GitHub-hosted runners and reuses these scripts rather than reimplementing them.

* Pull requests touching `ros2-base-jazzy-deb/` or `scripts/`, and pushes to
  `b-controlled-box/jazzy`, build the `amd64` and `arm64` snaps to verify they
  still pack. Each `.snap` is kept as an Actions artifact for 14 days on pull
  requests and for 90 days - GitHub's maximum - on branch builds.
* Pushing a tag matching `v*` additionally publishes both `.snap` files as assets
  of the corresponding GitHub Release. Artifacts always expire by age, so a
  Release is the only permanent home for a build.

Both architectures build on native runners (`ubuntu-24.04` and
`ubuntu-24.04-arm`), which are free for public repositories.

`snap/snapcraft.yaml` remains the source of truth for the snap version. The tag
and the version in the asset file name may therefore differ; the workflow emits a
warning when they do, but does not fail.

## About

SPDX-FileCopyrightText: Copyright (c) 2023-2026 Bosch Rexroth AG

<https://www.boschrexroth.com/en/dc/imprint/>

## Licenses

SPDX-License-Identifier: MIT
