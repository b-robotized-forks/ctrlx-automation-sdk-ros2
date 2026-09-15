#!/bin/bash
set -e

# Builds the b-robotized ROS 2 overlay packages that are dumped into the base
# snap by the 'b-robotized-overlay-packages' part of snap/snapcraft.yaml.
#
# The overlay is NOT part of this repository, it is built from a separate
# repository and therefore has to be generated before 'snapcraft pack' runs.
#
# Output: ./b_robotized_overlay_install
#   This is exactly the path the 'b-robotized-overlay-packages' part refers to
#   with 'source: ./b_robotized_overlay_install'. Snapcraft resolves relative
#   source paths against the directory snapcraft is started from, which is this
#   directory - not snap/.
#
# The colcon workspace is kept outside of this directory on purpose: the
# 'ros-base' part uses 'source: ./' together with the colcon plugin, so a 'src/'
# directory here would be picked up and built a second time inside the snap.

OVERLAY_REPO=${OVERLAY_REPO:-https://github.com/ros-controls/foreman.git}
OVERLAY_REF=${OVERLAY_REF:-master}
OVERLAY_PACKAGES=${OVERLAY_PACKAGES:-foreman_msgs}
ROS_DISTRO=${ROS_DISTRO:-jazzy}

SNAP_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(git rev-parse --show-toplevel)

WS_DIR="${ROOT_DIR}/.overlay-ws"
INSTALL_DIR="${SNAP_DIR}/b_robotized_overlay_install"

echo "-------------------------------------------------------"
echo "build overlay packages: ${OVERLAY_PACKAGES}"
echo "  repo:    ${OVERLAY_REPO}"
echo "  ref:     ${OVERLAY_REF}"
echo "  install: ${INSTALL_DIR}"
echo "-------------------------------------------------------"

rm -rf "${WS_DIR}" "${INSTALL_DIR}"
mkdir -p "${WS_DIR}/src"

# 'git clone --branch' only accepts branch and tag names, so fetch the ref
# explicitly - that way OVERLAY_REF can also be a commit SHA.
SRC_DIR="${WS_DIR}/src/$(basename "${OVERLAY_REPO}" .git)"
git init -q "${SRC_DIR}"
git -C "${SRC_DIR}" remote add origin "${OVERLAY_REPO}"
git -C "${SRC_DIR}" fetch -q --depth 1 origin "${OVERLAY_REF}"
git -C "${SRC_DIR}" checkout -q FETCH_HEAD

pushd "${WS_DIR}" >/dev/null

  # shellcheck disable=SC1090
  source "/opt/ros/${ROS_DISTRO}/setup.bash"

  rosdep install --from-paths src --ignore-src --rosdistro "${ROS_DISTRO}" -r -y

  # OVERLAY_PACKAGES is deliberately unquoted, it may name several packages
  # shellcheck disable=SC2086
  colcon build \
      --packages-up-to ${OVERLAY_PACKAGES} \
      --merge-install \
      --install-base "${INSTALL_DIR}"

popd >/dev/null

echo "Overlay packages installed to ${INSTALL_DIR}"
