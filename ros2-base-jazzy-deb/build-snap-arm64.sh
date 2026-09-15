#!/bin/bash
set -e

# 'sudo' is required independently of the snapcraft version (here 8.x)
# Requires a native arm64 build host.
sudo snapcraft clean
sudo SNAPCRAFT_BUILD_ENVIRONMENT=host snapcraft pack --build-for=arm64 --verbosity=verbose
