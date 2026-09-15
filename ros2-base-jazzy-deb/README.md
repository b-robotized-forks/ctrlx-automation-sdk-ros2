# ROS 2 Jazzy on ctrlX OS: A Snap Implementation of the ROS 2 Jazzy Distribution using ROS 2 Debian Package

## Introduction

We recommend for ROS 2 applications running on a ctrlX OS this approach:

* Build and install a __base snap__ containing the ROS 2 runtime and the components used for the ctrlX Data Layer access.
* This base snap provides its components using the snap [content interface](https://snapcraft.io/docs/content-interface).
* Pack your ROS 2 application into one or more overlay snaps.
* Let these overlay snap use the ROS 2 runtime and the ctrlX Data Layer via the content interface of the __base snap__.

This documentation describes how the base snap `ros2-base` can be build.

!!! important
    The build for arm64 devices uses Docker and is in an unreleased state!

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

The script clones [ros-controls/foreman](https://github.com/ros-controls/foreman),
builds `foreman_msgs` with colcon and installs the result into
`./b_robotized_overlay_install`. The colcon workspace itself is created in
`.overlay-ws/` at the repository root, deliberately outside this directory: the
`ros-base` part uses `source: ./` with the colcon plugin, so a `src/` directory
here would be built a second time inside the snap.

`OVERLAY_REPO`, `OVERLAY_REF` and `OVERLAY_PACKAGES` override the defaults, for
example to pin the overlay to a fixed commit for a reproducible release:

        OVERLAY_REF=<commit-sha> ./build-overlay-packages.sh

### AMD64

Compiling for AMD64 on an AMD64 machine is straight-forward. With the prerequisites and the overlay packages above in place, nothing beyond the `snap/snapcraft.yaml` file and a shell script that calls snapcraft is needed here.

Call:

        ./build-snap-amd64.sh

### ARM64

We recommend using a native ARM64 host environment to compile the ARM64 code. Set up a corresponding hardware, for example __Raspberry Pi__ or a virtual environment, for example __Qemu__ [installation scripts](https://github.com/boschrexroth/ctrlx-automation-sdk/tree/main/scripts/environment).

## Continuous Integration

`.github/workflows/build-snap-ros2-base.yml` performs exactly the steps above on
GitHub-hosted runners and reuses these scripts rather than reimplementing them.

* Pull requests touching `ros2-base-jazzy-deb/` or `scripts/`, and pushes to
  `b-controlled-box/jazzy`, build the `amd64` snap to verify it still packs. The
  `.snap` file is kept as an Actions artifact for 7 days.
* Pushing a tag matching `v*` additionally publishes the `.snap` as an asset of
  the corresponding GitHub Release.

Only `amd64` is built in CI. ARM64 still requires a native ARM64 build host and
is not part of the released set.

`snap/snapcraft.yaml` remains the source of truth for the snap version. The tag
and the version in the asset file name may therefore differ; the workflow emits a
warning when they do, but does not fail.

## About

SPDX-FileCopyrightText: Copyright (c) 2023-2026 Bosch Rexroth AG

<https://www.boschrexroth.com/en/dc/imprint/>

## Licenses

SPDX-License-Identifier: MIT
