#!/bin/bash
set -e

# Builds the ROS 2 overlay packages that are dumped into the base snap by the
# 'b-robotized-overlay-packages' part of snap/snapcraft.yaml.
#
# The overlay is NOT part of this repository, it is built from the sources listed
# in ./overlay.repos and therefore has to be generated before 'snapcraft pack'.
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

ROS_DISTRO=${ROS_DISTRO:-jazzy}

SNAP_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(git rev-parse --show-toplevel)

OVERLAY_REPOS_FILE=${OVERLAY_REPOS_FILE:-${SNAP_DIR}/overlay.repos}
OVERLAY_PACKAGES=${OVERLAY_PACKAGES:-foreman_msgs franka_msgs}

WS_DIR="${ROOT_DIR}/.overlay-ws"
INSTALL_DIR="${SNAP_DIR}/b_robotized_overlay_install"

echo "-------------------------------------------------------"
echo "build overlay packages: ${OVERLAY_PACKAGES}"
echo "  repos:   ${OVERLAY_REPOS_FILE}"
echo "  install: ${INSTALL_DIR}"
echo "-------------------------------------------------------"

rm -rf "${WS_DIR}" "${INSTALL_DIR}"
mkdir -p "${WS_DIR}/src"

# Not shallow: 'version' in overlay.repos may be a commit SHA, which a shallow
# clone cannot check out.
vcs import "${WS_DIR}/src" --input "${OVERLAY_REPOS_FILE}"

pushd "${WS_DIR}" >/dev/null

  # shellcheck disable=SC1090
  source "/opt/ros/${ROS_DISTRO}/setup.bash"

  # Resolve dependencies only for the packages actually being built.
  # shellcheck disable=SC2086
  mapfile -t pkg_paths < <(colcon list --packages-up-to ${OVERLAY_PACKAGES} --paths-only)
  echo "resolving dependencies for: ${pkg_paths[*]}"
  rosdep install --from-paths "${pkg_paths[@]}" --ignore-src --rosdistro "${ROS_DISTRO}" -r -y

  # OVERLAY_PACKAGES is deliberately unquoted, it may name several packages
  # shellcheck disable=SC2086
  colcon build \
      --packages-up-to ${OVERLAY_PACKAGES} \
      --merge-install \
      --install-base "${INSTALL_DIR}"

popd >/dev/null

echo "Overlay packages installed to ${INSTALL_DIR}"
